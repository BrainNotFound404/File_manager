# University Project

This is a repo of a project that I have to make for my University (Faculty of Mathematics and Infomatics, Bucharest, Romania)

The project is required to be on x86 Assembly, but first I will implement it in C++ to see the structure of the code

# Unidimensional and Bidimensional Memory System Implementation

## Overview
This project implements a file storage system with both **unidimensional** and **bidimensional** memory models. The system efficiently manages file storage, retrieval, deletion, and defragmentation.

## Unidimensional Memory System
In this model, the storage device operates under the following constraints:
- The device has a fixed storage capacity of **8MB**.
- The storage is divided into blocks of **8KB** each.
- A block can store content from only **one file**.
- A file requires at least **two blocks** for storage.
- Files must be stored **contiguously**.
- If contiguous space is unavailable, the file **cannot be stored**.
- The system does not have a directory structure; files are identified using a unique **file descriptor (ID)** (a natural number between 1 and 255), allowing storage of a maximum of **255 files**.

### Supported Operations
1. **GET (Retrieve File Location)**
   - Given a file descriptor, return the block range `(start, end)` where the file is stored.
   
2. **ADD (Store a File)**
   - Given a file descriptor and size in KB, return the first available block range from left to right.
   - If storage is not possible, return `(0, 0)`.

3. **DELETE (Remove a File)**
   - Given a file descriptor, release the occupied blocks (assign them the value `0`).

4. **DEFRAGMENTATION**
   - Reorganize blocks so that files are stored compactly (starting from block `0`, filling consecutive blocks without gaps).

### Input Format
- The first line contains the number `O` (number of operations).
- Each following line represents an operation:
  - `1` - **ADD**
  - `2` - **GET**
  - `3` - **DELETE**
  - `4` - **DEFRAGMENTATION**

#### ADD Operation Format:
- The next line contains `N`, the number of files to be added.
- The next `2N` lines contain pairs: file descriptor and file size in KB.
- Output the stored file locations in the format:  
  ```
  %d: (%d, %d)
  ```
  If a file cannot be stored, output:
  ```
  fd: (0, 0)
  ```

#### GET Operation Format:
- Given a file descriptor, output its storage interval `(start, end)` or `(0, 0)` if it doesn't exist.

#### DELETE Operation Format:
- Given a file descriptor, delete the file from memory.

#### DEFRAGMENTATION Operation Format:
- Output memory after defragmentation, maintaining the ADD output format.

---

## Bidimensional Memory System
After implementing the unidimensional model, we extend it to **two dimensions**, creating an **8MB x 8MB** matrix of blocks. Contiguous storage is now defined **row-wise**.

### Supported Operations
1. **GET (Retrieve File Location)**
   - Given a file descriptor, return the block range `((startX, startY), (endX, endY))`.
   
2. **ADD (Store a File)**
   - Return the first available contiguous block region in the matrix.
   - If storage is not possible, return `((0,0), (0,0))`.

3. **DELETE (Remove a File)**
   - Release the occupied blocks by assigning them the value `0`.

4. **DEFRAGMENTATION**
   - Compact files in memory, moving gaps to the **bottom-right**.

5. **CONCRETE (Load from Filesystem)**
   - Reads real files from a given **absolute file path**, calculates their descriptors and sizes, and adds them to memory.
   - The descriptor is calculated as:
     ```
     fd = (actual_descriptor % 255) + 1
     ```
   - If a duplicate descriptor is found, output it but **do not store it**.

### Input Format
- The first line contains `O`, the number of operations.
- Each following line represents an operation:
  - `1` - **ADD**
  - `2` - **GET**
  - `3` - **DELETE**
  - `4` - **DEFRAGMENTATION**
  - `5` - **CONCRETE**

#### ADD Operation Format:
- The next line contains `N`, the number of files to be added.
- The next `2N` lines contain pairs: file descriptor and file size in KB.
- Output stored file locations in the format:
  ```
  %d: ((%d, %d), (%d, %d))
  ```
  If a file cannot be stored, output:
  ```
  fd: ((0, 0), (0, 0))
  ```

#### CONCRETE Operation Format:
- Input: `5` followed by an **absolute folder path** containing text files.
- The program will:
  - Determine the file descriptor and size.
  - Store them in bidimensional memory using **ADD**.
  - Print descriptor and size, along with memory location.
  - If a descriptor repeats, output:
    ```
    fd: ((0, 0), (0, 0))
    ```
    but **do not add it to memory**.

## Notes
- The system simulates a **basic file storage system** without hierarchical directories.
- **Defragmentation** is crucial for optimizing memory usage.
- The **bidimensional model** is an extension of the unidimensional model, offering a more scalable approach to storage management.

---

## Example Usage
### Sample Input:
```
5
1
2
10 32
20 16
2
10
3
10
4
```

### Sample Output:
```
10: (0, 3)
20: (4, 5)
(0, 3)
(4, 5)
Memory updated (file 10 deleted)
Defragmentation completed
```

---


