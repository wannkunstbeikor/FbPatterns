#pragma once

#include <fb/obfsheader.pat>
#include <fb/dbobject.pat>

namespace fb
{
    struct ObfuscatedDbObject
    {
        ObfuscationHeader obfsHeader;
        DbObject dbObject;
    };
}