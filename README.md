# FbPatterns
Collection of ImHex patterns for Frostbite file formats.

## Usage
Put the .pat files in the include/fb folder of your ImHex installation.

## DbObject
Basic DbObject pattern, format commonly used by the Engine.
```
#include <fb/dbobject.pat>

fb::DbObject object @0;
```
## ObfuscatedDbObject
Used for the layout.toc file and the SuperBundle toc files of games until ca. 2017.
```
#include <fb/obfsdbobject.pat>

fb::ObfuscatedDbObject object @0;
```
## BinarySuperBundleToc
Used for SuperBundle toc files in games since ca. 2017.
```
#include <fb/binarysbtoc.pat>

fb::BinarySuperBundleToc toc @0;
```
