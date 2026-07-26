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

#pragma once

#include <libyul/backends/evm/ssa/ShuffleTrace.h>

#include <utility>
#include <vector>

namespace solidity::yul::ssa
{

struct BlockLayout
{
	// stack layout required to enter the block
	StackData stackIn;
	// stack layout required to execute the i-th operation in the block
	std::vector<StackData> operationIn;
	// stack layout required to handle the exit of the block
	StackData exitIn;

	// Recorded shuffle traces realizing the layouts above. Traces are positional, so they can be replayed on any
	// stack that is layout-compatible with the one they were recorded on (junk slots acting as wildcards).

	/// Transforms the stack after the (i-1)-th operation (`stackIn` for i = 0) into `operationIn[i]`
	std::vector<ShuffleTrace> operationShuffles;
	/// Transforms the stack after the last operation into `exitIn`
	ShuffleTrace exitShuffle;
	/// Per predecessor edge: transforms the predecessor's post-exit stack (for conditional jumps: after
	/// popping the condition) into the phi preimage of `stackIn` under that edge
	std::vector<std::pair<SSACFG::BlockId, ShuffleTrace>> tracesForStackIn;

	/// The recorded shuffle for the edge from `_predecessor` into this block
	ShuffleTrace const& traceForStackIn(SSACFG::BlockId const& _predecessor) const
	{
		for (auto const& [parent, trace]: tracesForStackIn)
			if (parent == _predecessor)
				return trace;
		yulAssert(false, fmt::format("no recorded shuffle for predecessor edge from block {}", _predecessor));
		solidity::util::unreachable();
	}
};

/// For each (reachable) block in the SSACFG one block layout
class SSACFGStackLayout
{
public:
	SSACFGStackLayout(std::size_t const _numBlocks): m_blockLayouts(_numBlocks) {}

	std::optional<BlockLayout>& operator[](SSACFG::BlockId const& _blockId)
	{
		yulAssert(_blockId.hasValue() && _blockId.value < m_blockLayouts.size());
		return m_blockLayouts[_blockId.value];
	}

	std::optional<BlockLayout> const& operator[](SSACFG::BlockId const& _blockId) const
	{
		yulAssert(_blockId.hasValue() && _blockId.value < m_blockLayouts.size());
		return m_blockLayouts[_blockId.value];
	}

private:
	std::vector<std::optional<BlockLayout>> m_blockLayouts;
};

}
