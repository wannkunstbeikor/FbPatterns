#pragma once

// these files can get really large so we need to increase the limit
#pragma pattern_limit 0x4000

#include <std/io.pat>

#include <fb/obfsheader.pat>
#include <fb/guid.pat>

namespace fb
{
    namespace BinarySuperBundleToc
    {
        bitfield Flags
        {
            unused : 29;
            bool HasHuffmanTable : 1;
            bool HasBaseChunks : 1;
            bool HasBaseBundles : 1;
        };

        struct Header
        {
            be u32 pBundleHashMap;
            be u32 pBundleInfo;
            be u32 bundleCount;

            be u32 pChunkHashMap;
            be u32 pChunkInfo;
            be u32 chunkCount;

            // probably sth crypto related not used in any of the released games using this format
            be u32 pUnk1;
            be u32 pUnk2;

            be u32 pStringTable;

            // just a u32 array with data for the superbundle chunks
            be u32 pChunkData;
            be u32 chunkDataCount;

            be Flags flags;

            if (flags.HasHuffmanTable)
            {
                // newer games use a huffman table to compress the strings
                be u32 stringCount;
                be u32 huffmanNodeCount;
                be u32 phuffmanTable;
            }
            else
            {
                u32 stringCount = 0;
                u32 huffmanNodeCount = 0;
                u32 phuffmanTable = 0;
            }
        };

        struct BundleInfo
        {
            be u32 nameOffset [[hidden]];

            if (parent.header.flags.HasHuffmanTable)
            {
                std::error("Huffman table is not implemented yet.");
            }
            else
            {
                char name[] @ addressof(parent.header) + parent.header.pStringTable + nameOffset;
            }

            be u32 bundleSize;
            be u64 bundleOffset;
        };

        bitfield CasRef
        {
            unused : 8;
            bool isPatch : 8;
            casIndex : 8;
            installChunkIndex : 8;
        };

        struct ChunkInfo
        {
            fb::GUID chunkId;
            be u32 flagAndIndex;

            u32 dataIndex = flagAndIndex & 0x00FFFFFF;
            CasRef casRef @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 0);
            be u32 offset @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 1);
            be u32 size @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 2);
        };
    }

    struct BinarySuperBundleToc
    {
        ObfuscationHeader obfsheader;

        BinarySuperBundleToc::Header header;

        be u32 bundleHashMap[header.bundleCount] @ addressof(header) + header.pBundleHashMap;

        BinarySuperBundleToc::BundleInfo bundleInfos[header.bundleCount] @ addressof(header) + header.pBundleInfo;

        be u32 chunkHashMap[header.chunkCount] @ addressof(header) + header.pChunkHashMap;

        BinarySuperBundleToc::ChunkInfo chunkInfos[header.chunkCount] @ addressof(header) + header.pChunkInfo;
    };
}