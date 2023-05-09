#pragma once

#include <std/io.pat>

namespace fb
{
    struct SHA1
    {
        u32 a;
        u32 b;
        u32 c;
        u32 d;
        u32 e;
    } [[sealed, format("fb::impl::format_sha1")]];

    namespace impl
    {
        fn format_sha1(SHA1 sha1)
        {
	        return std::format("{{{:08X}{:08X}{:08X}{:08X}}}",
	            be u32(sha1.a),
                be u32(sha1.b),
                be u32(sha1.c),
                be u32(sha1.d));
	    };
	}
}