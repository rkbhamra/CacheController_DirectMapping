# CacheController_DirectMapping
(a) Symbol Diagram
The diagram in Figure 1, shows the input and output ports of all the modules (CPU, Cache and SDRAM Controller). The cache controller module and Cache SRAM module together make the Cache module. It also shows the relationship between all the module symbols using data and address buses. The buses are bolded and the non-bolded lines are single bit signals. 
![image](https://github.com/user-attachments/assets/20499529-0fda-4370-8780-89735b72b1a4)
(b) Block Diagram
The block diagram in Figure 2 provides a high-level view of the system, illustrating the function relationships and dependencies. It shows where the Address from the CPU goes, how it gets split up in the AWR as TAG, INDEX and OFFSET, and is then sent to the cache controller for tag-compare and v-bit comparison. If both are 1, it is a hit and in other scenarios, it will be a miss. The mux is purely representational and is not included in the design. It shows what hit/miss output would be based on the tag-compare and v-bit value of the block with index, INDEX.
![image](https://github.com/user-attachments/assets/2cbe971d-8d2f-4b22-bbbe-52caba63d114)

Hit/Miss timing
As can be seen in Waveform 2, the CPU wants to write AA to 0x1100, but the cache doesn't have 0x1100 in any of its blocks. So the cache controller calls to the memory and turns on the mem_strobe as it sends in the address that it wants to read from,  and starts reading from the memory with wr_rd_m set to 1 (as read is an active high for the main memory). The time to check whether or not it was a hit was 2ns. This can be confirmed by looking at the pointers X and O. X is where the cache controller got the address 0x1100 from the CPU and O is when the cache controller sent 0x1100 to the main memory, setting MemAddr_SDRAM to 0x1100.
![image](https://github.com/user-attachments/assets/3203fa8d-8b18-4255-a7f1-fd1111ef65a2)
Waveform 2:  Time taken to determine a hit or a miss

Data Access Time
The CPU requests data from 0x5504 but the cache doesn’t have it; i.e.; it is a miss. So it starts accessing the data from the main memory from 0x5500 to 0x551F when the cache turns on the MemStrb_SDRAM signal and stops reading it when the signal changes to 0 back again. Looking at the position of the pointers, it takes the cache 65ns to access data from the main memory, since it won’t read back the value at offset 0x4 to the CPU until it has written the whole memory block to the cache.
![image](https://github.com/user-attachments/assets/3e120c0e-48f7-4896-98ba-14a5b7cbcf7e)
Waveform 3:  Data Access Time for address 5504

Block Replacement Time
Block replacement accounts for two actions. One is where it has to write the existing block in the cache to the main memory and the second is where it has to read a new block from the main memory into the cache. In the example of Waveform 4, the data in the cache INDEX 0 was data of the block 0x1100-0x111F of the main memory. The cache first writes back the block at INDEX 0 to the starting address of 0x1100 in the main memory and then starts loading in the new block from 0x5500-0x551F of the main memory into the cache block at INDEX 0. The total time for this is 131ns. 
![image](https://github.com/user-attachments/assets/b4cfe0dd-fcad-47c5-b539-d655aee2b493)
Waveform 4:  INDEX 0x0 block changed from 0x1100-0x111F to 0x5500-0x551F

Hit Time (Case 1 & 2)
When the block is present in the cache and valid-bit is 1 for the block, the cache can directly read the value at the offset back to the CPU without accessing main memory data. In the case of Waveform 5, the data from the main memory block 0x1100-0x111F was written to index 0 of cache memory and the valid-bit was set. Now when the CPU tries to read from 0x1102, the tags at index 0 match and the data is valid, so the cache directly reads back to the CPU without involving the main memory. The data access time in the case when it is a hit, including the time it takes to determine a hit/miss is 6ns.
![image](https://github.com/user-attachments/assets/2872bb99-3cee-4a89-bec7-0d4a717d68d7)
Waveform 5:  Hit/miss determination + data access time for a hit

Miss Penalty for D-bit = 0
When the dirty-bit for a block is 0, the cache doesn’t need to write the block back to main memory from the cache because no values were edited. But it is still a miss, so the miss penalty would be the total time the operation takes, minus the time it would have taken if it were a hit. The total time for the cache to read from 0x4444 (write block 0x4440-0x445f to cache from main memory) and send it to the CPU is 69ns.
Miss Penalty = Total time of the operation - Hit time = 69ns - 6ns = 63ns
![image](https://github.com/user-attachments/assets/faa0107b-7067-4fd9-b580-ae0bb3032181)
Waveform 6:  D-bit = 0, Miss Penalty = Total time of the operation - Hit time

Miss Penalty for D-bit = 1
When Dirty-bit is 1 and the block needs to be replaced, the cache first needs to write back to memory. So the miss penalty for this scenario would be the total time for the operation minus the hit time. 
Miss Penalty in the given scenario = 135ns - 6ns = 129ns
![image](https://github.com/user-attachments/assets/b98f2104-1de0-4b6b-8b53-9205878f22c5)
Waveform 7:  D-bit = 1, Miss Penalty = Total time - Hit time

Table 1: Tabulated summary of the results
![image](https://github.com/user-attachments/assets/52fdc47c-e4ca-4302-8457-50028d1ff601)


