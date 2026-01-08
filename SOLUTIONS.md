# LinGam CTF Solutions

This document contains solutions for all Linux CTF challenges in the LinGam repository.

---

## 1. Archives

**Challenge Description:**
- **Mode:** Oneliner (single command)
- **Objective:** Extract flag pieces from nested archives

**Task Details:**
The challenge creates multiple archive files (`.gz`, `.tar`, `.zip`) containing individual characters of the flag: `flag_is_super_archive`

**Solution:**

```bash
for f in challenges/*; do ext="${f##*.}"; case "$ext" in gz) gunzip -c "$f" ;; tar) tar -xOf "$f" ;; zip) unzip -p "$f" ;; esac; done
```

**Explanation:**
1. Loop through all files in the `challenges` directory
2. Extract the file extension
3. Use appropriate extraction tool based on extension:
   - `gunzip -c` for `.gz` files (output to stdout)
   - `tar -xOf` for `.tar` files (extract to stdout)
   - `unzip -p` for `.zip` files (pipe to stdout)
4. The characters are printed in order, forming the flag

**Flag:** `flag_is_super_archive`

---

## 2. BanMe

**Challenge Description:**
- **Mode:** Suicide mode (no errors allowed) + Time mode (30 seconds)
- **Objective:** Find the external IP with the most BAN attempts in fail2ban.log

**Task Details:**
The challenge generates a fail2ban log with many entries. One external IP (192.0.0.0/8 range) has exactly 2050 BAN entries - more than any other IP.

**Solution:**

```bash
grep "BAN" fail2ban.log | grep -E "192\.|193\.|194\.|195\.|196\.|197\.|198\.|199\.|200\.|201\.|202\.|203\.|204\.|205\.|206\.|207\." | awk '{print $NF}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}'
```

**Explanation:**
1. Filter lines containing "BAN" status
2. Filter for external IP addresses (not 10.x.x.x internal range)
3. Extract the IP address (last field)
4. Count occurrences of each IP
5. Sort numerically in reverse order
6. Take the top result
7. Extract just the IP address

**Alternative shorter solution:**

```bash
awk '/BAN/ && !/10\./ {print $NF}' fail2ban.log | sort | uniq -c | sort -nr | head -1 | awk '{print $2}'
```

**Flag:** The IP address with the most BAN attempts (dynamically generated, typically in 192-207 range)

---

## 3. DeleteFile

**Challenge Description:**
- **Objective:** Delete a file that prevents the program from running

**Task Details:**
The Go program checks if `/root/dontdelete` exists. If it doesn't exist, it prints the flag.

**Solution:**

```bash
rm /root/dontdelete && ./main
```

**Explanation:**
1. Delete the `/root/dontdelete` file
2. Run the `./main` program
3. The program checks for the file and prints the flag when it's not found

**Flag:** `f3334634006f810113f4d18526d3ea11`

---

## 4. DoTheMathIn30Seconds

**Challenge Description:**
- **Mode:** Suicide mode (no errors allowed) + Time mode (30 seconds)
- **Objective:** Calculate the sum of PIDs from forked processes

**Task Details:**
The `task.py` script creates 20 child processes. You need to find all PIDs of processes named "task.py", sum them, and pass the sum to `./main`.

**Solution:**

```bash
./main $(ps aux | grep task.py | grep -v grep | awk '{sum+=$2} END {print sum}')
```

**Explanation:**
1. Use `ps aux` to list all processes
2. Filter for processes containing "task.py"
3. Exclude the grep process itself
4. Sum all PIDs (column 2) using awk
5. Pass the sum as an argument to `./main`

**Alternative solution:**

```bash
./main $(pgrep -f task.py | awk '{sum+=$1} END {print sum}')
```

**Flag:** Depends on the calculated sum (dynamically generated)

---

## 5. KnockKnock

**Challenge Description:**
- **Objective:** Perform port knocking to open the web server on port 4444

**Task Details:**
A web server on port 4444 is protected by port knocking. You need to knock on ports 1001 through 1010 in sequence to unlock it.

**Solution:**

```bash
for port in {1001..1010}; do nc -zv localhost $port 2>&1; done && sleep 1 && curl localhost:4444
```

**Explanation:**
1. Loop through ports 1001 to 1010
2. Use `nc -zv` to perform port scanning (knocking)
3. Wait 1 second for the service to open
4. Access the web server on port 4444 using curl

**Alternative using nmap:**

```bash
for port in {1001..1010}; do nmap -p $port localhost; done && curl localhost:4444
```

**Flag:** `port_knocking_service.` (from the web server response)

---

## 6. LargeFile

**Challenge Description:**
- **Objective:** Find a password in a large file with specific characteristics

**Task Details:**
The password is hidden in a file that:
- Has exactly 3314 lines
- Belongs to group `ctfuser`
- Contains a line that is exactly 43 characters long

**Solution:**

```bash
find / -type f -group ctfuser 2>/dev/null | while read f; do [ $(wc -l < "$f" 2>/dev/null) -eq 3314 ] && awk 'length($0)==43' "$f"; done
```

**Explanation:**
1. Find all files belonging to group `ctfuser`
2. For each file, check if it has exactly 3314 lines
3. If yes, search for lines with exactly 43 characters
4. Print matching lines

**Alternative simpler solution if you know the file location:**

```bash
awk 'length($0)==43' large_text_file.txt
```

**Flag:** `You find my little secrets: UnicornPony9433`

---

## 7. MoldovaVirus

**Challenge Description:**
- **Objective:** Collect password pieces scattered across many files in a directory tree

**Task Details:**
Files with numeric names (0, 1, 2, etc.) are scattered in random directories under `/root/challenge`. Each file contains its index and one character of the flag: `flagissuperfounder`

**Solution:**

```bash
find /root/challenge -type f | xargs grep -h "^[0-9]" | sort -n | awk '{print $2}' | tr -d '\n'
```

**Explanation:**
1. Find all files in the `/root/challenge` directory
2. Search for lines starting with a number (the index)
3. Sort numerically by index
4. Extract the second field (the character)
5. Remove newlines to concatenate all characters

**Alternative solution:**

```bash
for i in {0..18}; do find /root/challenge -type f -exec grep -l "^$i$" {} \; | head -1 | xargs grep "^$i$" | cut -d' ' -f2; done | tr -d '\n'
```

**Flag:** `flagissuperfounder`

---

## 8. PinCode

**Challenge Description:**
- **Mode:** Oneliner (single command)
- **Objective:** Brute force a 5-digit PIN code

**Task Details:**
The program checks if the provided PIN equals "15627" and prints the flag if correct.

**Solution:**

```bash
for pin in {10000..99999}; do ./main $pin | grep -q "flag" && echo $pin && ./main $pin && break; done
```

**Explanation:**
1. Loop through all 5-digit numbers (10000 to 99999)
2. Run `./main` with each PIN
3. Check if output contains "flag"
4. When found, print the PIN and the flag, then break

**Faster solution if you inspect the binary:**

```bash
strings main | grep -E "^[0-9]{5}$"
```

Or directly:

```bash
./main 15627
```

**Flag:** `you flag is super_pin_code_brure` (PIN: 15627)
*Note: The typos in the flag text are present in the original challenge code.*

---

## 9. ProjectFiles

**Challenge Description:**
- **Mode:** Oneliner (single command)
- **Objective:** Calculate the sum of filename lengths (without extensions) in /challenges

**Task Details:**
The challenge generates 150 random files with random names and extensions. You need to sum the length of all filenames (excluding the extension part).

**Solution:**

```bash
ls /challenges | sed 's/\.[^.]*$//' | awk '{sum+=length($0)} END {print sum}'
```

**Explanation:**
1. List all files in `/challenges` directory
2. Remove file extensions using sed
3. Calculate the length of each filename
4. Sum all lengths and print the result

**Alternative solution:**

```bash
for f in /challenges/*; do basename "$f" | sed 's/\.[^.]*$//' | wc -c; done | awk '{sum+=$1-1} END {print sum}'
```

**Flag:** The numerical sum of all filename lengths (dynamically generated)

---

## Summary

All challenges test various Linux command-line skills:

1. **Archives** - Archive manipulation (tar, gzip, unzip)
2. **BanMe** - Log analysis and text processing (grep, awk, sort)
3. **DeleteFile** - File operations and program execution
4. **DoTheMathIn30Seconds** - Process management (ps, pgrep)
5. **KnockKnock** - Port knocking and network tools (nc, curl)
6. **LargeFile** - File search and text filtering (find, awk)
7. **MoldovaVirus** - File system traversal and data extraction
8. **PinCode** - Brute forcing and loops
9. **ProjectFiles** - String manipulation and arithmetic operations

These challenges are designed to be solved with single Bash commands or short command chains, emphasizing efficiency and Linux command-line proficiency.
