> [!IMPORTANT]
> Work In Progress

# C Compiler Dec72
Resurrection attempt of the UNIX PDP-11 C Compiler from December 1972 (a.k.a. prestruct-c).

## Original Environment
- PDP-11/45 (native floating point and multiplication/division support)
- UNIX V3 beta
- Origin at `0`

## My Environment
- **Virt11** (my own PDP-11/20 simulator; currently private) for debugging and testing the compiler
  - UNIX V1 syscall simulation
    - Origin at `040000`
  - Built-in interactive debugger
    - Disassembly
    - Breakpoints (exec, read, write)
    - Register dump
    - Instruction trace
    - Register manipulation
    - Flag manipulation
    - Memory dump
  - Focus on accuracy and determinism rather than speed
  - Runs on Windows and Linux
- **Apout** for compiling/assembling the compiler
  - PDP-11/45 instructions
  - Very fast, sufficiently accurate
  - Supports virtually every PDP-11 binary
    - Origin at `0` or `040000` depending on the simulated UNIX version
  - Highly flexible

## The Compiler
- Written in the June 1972 (last1120c) syntax (i.e., `char []` for `char` pointer)
- Accepts a newer syntax (i.e., `char *` for `char` pointer)
  - Therefore, it cannot compile itself
- Not entirely compatible with the June 1972 compiler either
  - It uses negative integer constants in switch cases
- Missing all `.s` files
  - Some tables can be taken from other versions of the compiler

## Notes
- Does not work properly if assembled with the origin set to `040000`
  - The binary is too big, and some buffers are located at addresses > `0100000`
  - Pointers being effectively negative causes the following logic from `liba.a/put.o/fl` to misbehave:
    ```
	mov	r0,0f
	neg	r0
	add	4(r1),r0
	ble	1f
	mov	r0,0f+2
    ```
  - Can be fixed by replacing the above code with:
    ```
	mov	r0,0f
	cmp	4(r1),r0
	blos	1f
	neg	r0
	add	4(r1),r0
	mov	r0,0f+2
    ```
- Should be assembled with origin `0` to simulate its natural habitat, but it doesn't work:
  - `as` built from source code leftover on the 's1' tape can assemble source files with the relocation constant defaulted to `0`
  - However, the objects do not want to link, and I'm forced to switch back to `as` from the 's2' tape
  - The relocation constant can be manually changed to `0`
  - However, the `liba.a` and `libc.a` libraries hardcode it as `040000`
  - The source code of `libc` is available, and `libc` can be rebuilt to use `0` as the relocation constant
  - But the source code of `liba` is not available
    - The most important objects are `get.o` and `put.o`
    - I have disassembled them and ensured the re-assembled binaries match the original
    - They can be rebuilt with the relocation constant set to `0`
  - Running the executable after linking crashes:
    - I believe some pointers still use the relocation constant of `040000`
    - Perhaps the link editor `ld` plays a role?
- Forced to use `040000` as the origin with patched `get.o` to fix the negative pointer bug
- The assembler from the `s2` tape does not support the PDP-11/54 `MUL` instruction used by `c0t.s`
  - Can be worked around by replacing:
   ```
	mov	_cval,r1
	mul	base,r1
	add	r0,r1
    ```
    with:
    ```
	mov	_cval,r1
	mov	base,(r4)+
	mov	r1,(r4)
	mov	-(r4),r1
	add	r0,r1
    ```
- The June 1972 compiler does not support negative integer constants in switch cases. Therefore:
  ```c
		/* sort unmentioned */
		case -2:
			cs[0] = 5;		/* auto */
  ```
  needs to be replaced with:
  ```c
		/* sort unmentioned */
		case 0177776:	/* -2 */
			cs[0] = 5;		/* auto */
  ```
- Since the origin is not `040000` and the code assumes it to be `0`, `c00.c`, `c03.c`, and `c10.c` need to be modified accordingly.

## Todo
- Implement PDP-11/45 floating point and arithmetic instructions
- Implement UNIX V2 (and possibly V3) syscall simulation
- Switch environment and target to PDP-11/45 (currently the compiler generates PDP-11/20 code)
- Give origin `0` another try

## Changes Since June/July
A lot of changes have occurred, the biggest one probably being the way function calls are handled. For the following code:
```c
func1()
{
	func2();
}

func2() {}
```
The June 1972 compiler compiles it to something like this (pseudo-assembly):

```
.text
L0:
	CALL [_func2]
	RET
L1:
	RET
.data
_func1:
	.word	L0
_func2:
	.word	L1
```
This compiler removes the indirection and performs calls/jumps (`JSR` and `JMP`) directly:

```
.text
func1:
	CALL _func2
	RET
func2:
	RET
```
This effectively renders `libc.a` from the 's2' tape incompatible. Luckily, the source code of libc is available on the 'last1120c' tape, and it can be modified to work with code generated by this compiler.

Another change is the pointer declaration syntax. This compiler uses the modern pointer declaration syntax (`char *name;` instead of `char name[];`).

## Status
Almost nothing works (and by "nothing", I mean it, nothing), but at least it can compile this program with the very short-lived struct declaration syntax:

```c
struct foo (
	char x;
	int y;
	char *z;
);

main(argc, argv)
char **argv;
{
	struct foo bruh;
	bruh.x = 'C';
	bruh.y = 123;
	bruh.z = "test";
	printf("x = '%c', y = %d, z = \"%s\"\n", bruh.x, bruh.y, bruh.z);
}
```

If you rename the variable `bruh` to something else, like `bar`, it will throw an error saying `Unimplemented pointer conversion`. I have no idea why. I've also never gotten struct pointers to work - it always complains about `Illegal structure ref` when I try to use `->`. It also seems to accept `.` on structure pointers (and does not actually dereference the pointer when accessing the members), so something is probably very wrong with referencing and dereferencing.

## Files
- `bin` - binaries
  - `lib` - C runtime and library modified to work with code generated by this compiler
  - `with_float` - compiler binaries with floating point support enabled
  - `without_float` - compiler binaries with floating point support disabled (recommended)
- `samples` - sample `.c` source files and the `.s` files produced by the compiler
- `src_build` - source files for compiling using the toolchain from the 's2' tape
- `src` - source files for compiling using a hypothetical UNIX V3 beta toolchain; no changes to original C code
- `tools` - compiler and libraries used for compiling the compiler

## Build
`c0` and `c1` currently need to be built with different compilers and libraries. They're in the `tools` directory. It is suggested that you build this compiler without floating point support because floating point support increases the chance of the compiler outputting invalid assembly code. Make sure you use the toolchain from the 's2' tape and source files from `src_build`.
<pre>
# c0 - <u>COPY FILES FROM "tools/for_building_c0" TO "/usr/lib"</u>
cc -c c0[0123].c
______________________________________________________________________
# IF FLOAT SUPPORT
	EDIT c0t.s TO SET "fpp" TO "1"
# ELSE
	EDIT c0t.s TO SET "fpp" TO "0"
______________________________________________________________________
as c0t.s; mv a.out c0t.o
cc c0?.o; mv a.out c0

# c1 - <u>COPY FILES FROM "tools/for_building_c1" TO "/usr/lib"</u>
cc -c c1[01].c
as c1t.s; mv a.out c1t.o
cvopt < cctab.s > cctab.i; as cctab.i; mv a.out cctab.o
cvopt < efftab.s > efftab.i; as efftab.i; mv a.out efftab.o
cvopt < fptab.s > fptab.i; as fptab.i; mv a.out fptab.o
cvopt < regtab.s > regtab.i; as regtab.i; mv a.out regtab.o
cvopt < sptab.s > sptab.i; as sptab.i; mv a.out sptab.o
______________________________________________________________________
# IF FLOAT SUPPORT
	cc c1?.o <u>fptab.o</u> efftab.o cctab.o sptab.o; mv a.out c1
# ELSE
	cc c1?.o <u>regtab.o</u> efftab.o cctab.o sptab.o; mv a.out c1
______________________________________________________________________

# cleanup
rm *.o *.i
</pre>
