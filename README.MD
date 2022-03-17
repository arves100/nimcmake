# Cmake + Nim (language integration)
Language integration of Nim with CMake

This is the result of some hours/days of thinking of a solution to bypass the limitations without making a script/wrapper of Nim that would fix everything.

There might be bugs, issues, problems, possibility of your compiler exploding or even worse.

If you find this usefull, you are free to send an issue or a PR to fix some of this garbage.

### Funny things that might improve this
1. Have a nim generator that actually can generate single file without using projects or a nimcache
2. Having a "generate only" option in Nim without compiling object files
3. Having a new rule variable called "SOURCE_BASE" so we can do proper manipulation of nimcache files

### License
MIT
