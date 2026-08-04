/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
// SPDX-License-Identifier: GPL-3.0

/**
 * Property test for the evmasm BlockDeduplicator.
 *
 * For a random program of tagged blocks, executing the original and the deduplicated items must produce the same
 * observable outcome, meaning the same result state when interpreting through the items including the state of the
 * stack modulo jump tag values (which can change due to deduplication).
 */

#include <libevmasm/AssemblyItem.h>
#include <libevmasm/BlockDeduplicator.h>
#include <libevmasm/Instruction.h>
#include <libevmasm/SemanticInformation.h>

#include <fuzztest/fuzztest.h>
#include <gtest/gtest.h>

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <functional>
#include <iostream>
#include <iterator>
#include <map>
#include <ostream>
#include <set>
#include <sstream>
#include <utility>
#include <vector>

using namespace solidity;
using namespace solidity::evmasm;

namespace solidity::evmasm::test
{

namespace
{

std::size_t constexpr maxBlocks = 6;
std::size_t constexpr maxBodyLength = 8;
std::size_t constexpr stepLimit = 1000;

/// Counts how often deduplication actually changed a fuzzed program and reports it once at teardown.
class DeduplicationStats: public testing::Environment
{
public:
	static void record(bool const _changed)
	{
		++s_total;
		s_merged += static_cast<std::size_t>(_changed);
	}

	void TearDown() override
	{
		if (s_total > 0)
			std::cout << "BlockDeduplicator changed " << s_merged << " of " << s_total << " fuzzed programs." << std::endl;
	}

private:
	static std::size_t s_total;
	static std::size_t s_merged;
};
std::size_t DeduplicationStats::s_total = 0;
std::size_t DeduplicationStats::s_merged = 0;

[[maybe_unused]] testing::Environment* const g_deduplicationStats = testing::AddGlobalTestEnvironment(new DeduplicationStats);

/// Item of the symbolic representation of the symbolic stack
struct StackValue
{
	u256 data;
	bool isTag = false;  // indicates whether the stack value corresponds to a PushTag item
};

enum class HaltReason
{
	Stop,
	Return,
	Revert,
	Failure,
	UndefinedTagUse,  // tag value used as anything but a jump destination (or via DUP/SWAP/POP)
	StepLimit  // execution did not halt within stepLimit steps
};

struct ExecutionOutcome
{
	std::vector<StackValue> stack;
	std::map<u256, u256> memory;
	std::size_t steps = 0;
	HaltReason reason = HaltReason::Stop;
	std::vector<u256> haltArgs;  // offset and size popped by RETURN/REVERT
};

std::ostream& operator<<(std::ostream& _out, ExecutionOutcome const& _outcome)
{
	_out << "reason=" << static_cast<int>(_outcome.reason) << " steps=" << _outcome.steps << " haltArgs=[";
	for (u256 const& arg: _outcome.haltArgs)
		_out << " " << arg;
	_out << " ] memory={";
	for (auto const& [offset, value]: _outcome.memory)
		_out << " " << offset << ":" << value;
	_out << " } stack=[";
	for (StackValue const& slot: _outcome.stack)
		if (slot.isTag)
			_out << " tag:" << slot.data;
		else
			_out << " " << slot.data;
	return _out << " ]";
}

ExecutionOutcome execute(AssemblyItems const& _items)
{
	std::map<u256, std::size_t> tagPositions;
	for (std::size_t i = 0; i < _items.size(); ++i)
		if (_items[i].type() == Tag)
			tagPositions.emplace(_items[i].data(), i);

	std::vector<StackValue> stack;
	std::map<u256, u256> memory;
	std::size_t steps = 0;

	auto const pop = [&]() {
		StackValue const value = stack.back();
		stack.pop_back();
		return value;
	};

	std::size_t pc = 0;
	while (true)
	{
		if (pc >= _items.size())
			return {.stack = stack, .memory = memory, .steps = steps, .reason = HaltReason::Stop};  // running past the last item is an implicit STOP
		AssemblyItem const& item = _items[pc++];
		if (item.type() == Tag)
			continue;
		if (++steps > stepLimit)
			return {.reason = HaltReason::StepLimit};

		if (item.type() == Push)
		{
			stack.push_back({item.data(), false});
			continue;
		}
		if (item.type() == PushTag)
		{
			stack.push_back({item.data(), true});
			continue;
		}
		if (item.type() != Operation)
			return {.reason = HaltReason::Failure};

		Instruction const instruction = item.instruction();
		if (Instruction::DUP1 <= instruction && instruction <= Instruction::DUP16)
		{
			std::size_t const depth = static_cast<std::size_t>(instruction) - static_cast<std::size_t>(Instruction::DUP1) + 1;
			if (stack.size() < depth)
				return {.reason = HaltReason::Failure};
			stack.push_back(stack[stack.size() - depth]);
			continue;
		}
		if (Instruction::SWAP1 <= instruction && instruction <= Instruction::SWAP16)
		{
			std::size_t const depth = static_cast<std::size_t>(instruction) - static_cast<std::size_t>(Instruction::SWAP1) + 1;
			if (stack.size() < depth + 1)
				return {.reason = HaltReason::Failure};
			std::swap(stack.back(), stack[stack.size() - depth - 1]);
			continue;
		}

		switch (instruction)
		{
		case Instruction::STOP:
			return {.stack = stack, .memory = memory, .steps = steps, .reason = HaltReason::Stop};
		case Instruction::ADD:
		{
			if (stack.size() < 2)
				return {.reason = HaltReason::Failure};
			StackValue const a = pop();
			StackValue const b = pop();
			if (a.isTag || b.isTag)
				return {.reason = HaltReason::UndefinedTagUse};
			stack.push_back({a.data + b.data, false});
			break;
		}
		case Instruction::POP:
			if (stack.empty())
				return {.reason = HaltReason::Failure};
			pop();
			break;
		case Instruction::MLOAD:
		{
			if (stack.empty())
				return {.reason = HaltReason::Failure};
			StackValue const offset = pop();
			if (offset.isTag)
				return {.reason = HaltReason::UndefinedTagUse};
			auto const cell = memory.find(offset.data);
			stack.push_back({.data = cell == memory.end() ? u256(0) : cell->second, .isTag = false});
			break;
		}
		case Instruction::MSTORE:
		{
			if (stack.size() < 2)
				return {.reason = HaltReason::Failure};
			StackValue const offset = pop();
			StackValue const value = pop();
			if (offset.isTag || value.isTag)
				return {.reason = HaltReason::UndefinedTagUse};
			memory[offset.data] = value.data;
			break;
		}
		case Instruction::JUMP:
		{
			if (stack.empty())
				return {.reason = HaltReason::Failure};
			StackValue const destination = pop();
			auto const target = destination.isTag ? tagPositions.find(destination.data) : tagPositions.end();
			if (target == tagPositions.end())
				return {.reason = HaltReason::Failure};
			pc = target->second;
			break;
		}
		case Instruction::JUMPI:
		{
			if (stack.size() < 2)
				return {.reason = HaltReason::Failure};
			StackValue const destination = pop();
			StackValue const condition = pop();
			if (condition.isTag)
				return {.reason = HaltReason::UndefinedTagUse};
			if (condition.data != 0)
			{
				auto const target = destination.isTag ? tagPositions.find(destination.data) : tagPositions.end();
				if (target == tagPositions.end())
					return {.reason = HaltReason::Failure};
				pc = target->second;
			}
			break;
		}
		case Instruction::RETURN:
		case Instruction::REVERT:
		{
			if (stack.size() < 2)
				return {.reason = HaltReason::Failure};
			StackValue const offset = pop();
			StackValue const size = pop();
			if (offset.isTag || size.isTag)
				return {.reason = HaltReason::UndefinedTagUse};
			return {
				.stack = stack,
				.memory = memory,
				.steps = steps,
				.reason = instruction == Instruction::RETURN ? HaltReason::Return : HaltReason::Revert,
				.haltArgs = {offset.data, size.data}
			};
		}
		default:
			return {.reason = HaltReason::Failure}; // outside the modeled alphabet
		}
	}
}

/// Domain of single body items for a program with tags 1..._numBlocks
fuzztest::Domain<AssemblyItem> bodyItemDomain(std::size_t const _numBlocks)
{
	return fuzztest::OneOf(
		fuzztest::ElementOf<AssemblyItem>({
			Instruction::STOP,
			Instruction::ADD,
			Instruction::POP,
			Instruction::MLOAD,
			Instruction::MSTORE,
			Instruction::JUMP,
			Instruction::JUMPI,
			Instruction::DUP1,
			Instruction::DUP2,
			Instruction::SWAP1,
			Instruction::RETURN,
			Instruction::REVERT,
		}),
		fuzztest::Map(
			[](std::uint64_t const _constant) { return AssemblyItem{u256(_constant)}; },
			fuzztest::InRange<std::uint64_t>(0, 3)
		),
		fuzztest::Map(
			[](std::uint64_t const _tag) { return AssemblyItem{PushTag, u256(_tag)}; },
			fuzztest::InRange<std::uint64_t>(1, _numBlocks)
		)
	);
}

/// Concatenates blocks Tag(1) body_1 ... Tag(n) body_n into one item sequence.
AssemblyItems concatenateBodies(std::vector<AssemblyItems> const& _bodies)
{
	AssemblyItems items;
	for (std::size_t i = 0; i < _bodies.size(); ++i)
	{
		items.emplace_back(Tag, u256(i + 1));
		items.insert(items.end(), _bodies[i].begin(), _bodies[i].end());
	}
	return items;
}

/// Copies one whole block body over another so that the deduplicator finds a mergeable pair
AssemblyItems withDuplicateBlock(std::vector<AssemblyItems> _bodies, std::size_t const _source, std::size_t const _destination)
{
	std::size_t const sourceIndex = _source % _bodies.size();
	std::size_t const destinationIndex = _destination % _bodies.size();
	// terminate block to denote its end with respect to the equality operator
	_bodies[sourceIndex].emplace_back(Instruction::STOP);
	_bodies[destinationIndex] = _bodies[sourceIndex];
	AssemblyItems program{AssemblyItem{PushTag, u256(std::max(sourceIndex, destinationIndex) + 1)}};
	AssemblyItems const blocks = concatenateBodies(_bodies);
	program.insert(program.end(), blocks.begin(), blocks.end());
	return program;
}

fuzztest::Domain<AssemblyItems> programDomain()
{
	return fuzztest::FlatMap(
		[](std::size_t const _numBlocks) {
			auto const bodiesDomain =
				fuzztest::VectorOf(fuzztest::VectorOf(bodyItemDomain(_numBlocks)).WithMaxSize(maxBodyLength)).WithSize(_numBlocks);
			return fuzztest::OneOf(
				fuzztest::Map(concatenateBodies, bodiesDomain),
				fuzztest::Map(
					withDuplicateBlock,
					bodiesDomain,
					fuzztest::InRange<std::size_t>(0, maxBlocks - 1),
					fuzztest::InRange<std::size_t>(0, maxBlocks - 1)
				)
			);
		},
		fuzztest::InRange<std::size_t>(1, maxBlocks)
	);
}

/// Reference implementation of BlockDeduplicator::deduplicate() from commit 70198f157: an ordered set with a
/// lexicographic suffix comparator over a copy of the block iterator.
namespace reference
{

struct BlockIterator
{
	using iterator_category = std::forward_iterator_tag;
	using value_type = AssemblyItem const;
	using difference_type = std::ptrdiff_t;
	using pointer = AssemblyItem const*;
	using reference = AssemblyItem const&;

	BlockIterator(
		AssemblyItems::const_iterator _it,
		AssemblyItems::const_iterator _end,
		AssemblyItem const* _replaceItem = nullptr,
		AssemblyItem const* _replaceWith = nullptr
	):
		it(_it), end(_end), replaceItem(_replaceItem), replaceWith(_replaceWith) {}

	BlockIterator& operator++()
	{
		if (it == end)
			return *this;
		if (SemanticInformation::altersControlFlow(*it) && *it != AssemblyItem{Instruction::JUMPI})
			it = end;
		else
		{
			++it;
			while (it != end && it->type() == Tag)
				++it;
		}
		return *this;
	}

	bool operator==(BlockIterator const& _other) const { return it == _other.it; }
	bool operator!=(BlockIterator const& _other) const { return it != _other.it; }

	AssemblyItem const& operator*() const
	{
		if (replaceItem && replaceWith && *it == *replaceItem)
			return *replaceWith;
		else
			return *it;
	}

	AssemblyItems::const_iterator it;
	AssemblyItems::const_iterator end;
	AssemblyItem const* replaceItem = nullptr;
	AssemblyItem const* replaceWith = nullptr;
};

bool deduplicate(AssemblyItems& _items)
{
	// Compares indices based on the suffix that starts there, ignoring tags and stopping at
	// opcodes that stop the control flow.

	// Virtual tag that signifies "the current block" and which is used to optimize loops.
	// We abort if this virtual tag actually exists.
	AssemblyItem const pushSelf{PushTag, u256(-4)};
	if (
		std::count(_items.cbegin(), _items.cend(), pushSelf.tag()) ||
		std::count(_items.cbegin(), _items.cend(), pushSelf.pushTag())
	)
			return false;

	std::function<bool(std::size_t, std::size_t)> comparator = [&](std::size_t _i, std::size_t _j)
	{
		if (_i == _j)
			return false;

		// To compare recursive loops, we have to already unify PushTag opcodes of the
		// block's own tag.
		AssemblyItem pushFirstTag{pushSelf};
		AssemblyItem pushSecondTag{pushSelf};

		if (_i < _items.size() && _items.at(_i).type() == Tag)
			pushFirstTag = _items.at(_i).pushTag();
		if (_j < _items.size() && _items.at(_j).type() == Tag)
			pushSecondTag = _items.at(_j).pushTag();

		using diff_type = BlockIterator::difference_type;
		BlockIterator first{_items.begin() + static_cast<diff_type>(_i), _items.end(), &pushFirstTag, &pushSelf};
		BlockIterator second{_items.begin() + static_cast<diff_type>(_j), _items.end(), &pushSecondTag, &pushSelf};
		BlockIterator end{_items.end(), _items.end()};

		if (first != end && (*first).type() == Tag)
			++first;
		if (second != end && (*second).type() == Tag)
			++second;

		return std::lexicographical_compare(first, end, second, end);
	};

	std::map<u256, u256> replacedTags;
	std::size_t iterations = 0;
	for (; ; ++iterations)
	{
		std::set<std::size_t, std::function<bool(std::size_t, std::size_t)>> blocksSeen(comparator);
		for (std::size_t i = 0; i < _items.size(); ++i)
		{
			if (_items.at(i).type() != Tag)
				continue;
			auto it = blocksSeen.find(i);
			if (it == blocksSeen.end())
				blocksSeen.insert(i);
			else
				replacedTags[_items.at(i).data()] = _items.at(*it).data();
		}

		if (!BlockDeduplicator::applyTagReplacement(_items, replacedTags))
			break;
	}
	return iterations > 0;
}

}

}

static void DeduplicationPreservesBehavior(AssemblyItems const& _program)
{
	AssemblyItems optimized = _program;
	bool const changed = BlockDeduplicator{optimized}.deduplicate();
	DeduplicationStats::record(changed);

	// Unchanged program implies identical items
	if (!changed)
		return;

	ExecutionOutcome const original = execute(_program);
	ExecutionOutcome const deduplicated = execute(optimized);

	std::ostringstream context;
	context << "program: " << _program << " original: " << original << " deduplicated: " << deduplicated;
	SCOPED_TRACE(context.str());

	ASSERT_EQ(original.reason, deduplicated.reason);
	ASSERT_EQ(original.haltArgs, deduplicated.haltArgs);
	ASSERT_EQ(original.memory, deduplicated.memory);
	ASSERT_EQ(original.steps, deduplicated.steps);

	// The stacks are compared modulo tag identity as deduplication redirects tags
	ASSERT_EQ(original.stack.size(), deduplicated.stack.size());
	for (std::size_t i = 0; i < original.stack.size(); ++i)
	{
		ASSERT_EQ(original.stack[i].isTag, deduplicated.stack[i].isTag) << "stack slot " << i;
		if (!original.stack[i].isTag)
			ASSERT_EQ(original.stack[i].data, deduplicated.stack[i].data) << "stack slot " << i;
	}
}

FUZZ_TEST(BlockDeduplicatorProperty, DeduplicationPreservesBehavior).WithDomains(programDomain());

static void DeduplicationInvariants(AssemblyItems const& _program)
{
	AssemblyItems optimized = _program;
	bool const changed = BlockDeduplicator{optimized}.deduplicate();

	// deduplicate() reports a change iff the items actually changed.
	ASSERT_EQ(changed, optimized != _program);

	// Deduplication only redirects PushTags; it never adds, removes or otherwise alters items.
	ASSERT_EQ(optimized.size(), _program.size());
	for (std::size_t i = 0; i < optimized.size(); ++i)
		if (_program[i].type() == PushTag)
			ASSERT_EQ(optimized[i].type(), PushTag);
		else
			ASSERT_EQ(optimized[i], _program[i]);

	// Immediate fixed point: a second run finds nothing left to do.
	AssemblyItems rerun = optimized;
	ASSERT_FALSE(BlockDeduplicator{rerun}.deduplicate()) << "second run changed: " << optimized;
	ASSERT_EQ(rerun, optimized);
}

FUZZ_TEST(BlockDeduplicatorProperty, DeduplicationInvariants).WithDomains(programDomain());

static void DeduplicationMatchesReference(AssemblyItems const& _program)
{
	AssemblyItems optimized = _program;
	bool const changed = BlockDeduplicator{optimized}.deduplicate();

	AssemblyItems referenceItems = _program;
	bool const referenceChanged = reference::deduplicate(referenceItems);

	ASSERT_EQ(changed, referenceChanged);
	ASSERT_EQ(optimized, referenceItems);
}

FUZZ_TEST(BlockDeduplicatorProperty, DeduplicationMatchesReference).WithDomains(programDomain());

}
