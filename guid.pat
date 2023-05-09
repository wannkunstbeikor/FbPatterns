#pragma once

#include <std/io.pat>

namespace fb
{
    struct GUID
    {
        u32 a;
        u16 b;
        u16 c;
        u8 d[8];
    } [[sealed, format("type::impl::format_guid")]];

    namespace impl
    {
		fn format_guid(GUID guid)
        {
	        return std::format("{{{:08X}-{:04X}-{:04X}-{:02X}{:02X}-{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}}}",
	            guid.a,
	            guid.b,
	            guid.c,
	            guid.d[0],
	            guid.d[1],
	            guid.d[2],
	            guid.d[3],
	            guid.d[4],
	            guid.d[5],
	            guid.d[6],
	            guid.d[7]);
	    };
	}
}