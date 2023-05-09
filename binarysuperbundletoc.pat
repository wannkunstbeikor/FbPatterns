#pragma once

// these files can get really large so we need to increase the limit
#pragma pattern_limit 0x4000

#include <fb/obfsheader.pat>
#include <fb/guid.pat>

namespace fb
{
    namespace BinarySuperBundleToc
    {
        enum Flags : u32
        {
            None = 0,
            HasBaseBundles = 1 << 0,
            HasBaseChunks = 1 << 1,
            HasHuffmanTable = 1 << 2
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
        };

        struct BundleInfo
        {
            be u32 nameOffset [[hidden]];
            // TODO: huffman table
            char name[] @ addressof(parent.header) + parent.header.pStringTable + nameOffset;

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