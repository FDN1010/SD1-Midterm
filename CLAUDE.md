# Senior Design 1 – Midterm Report (Group 10)

**Project:** AMD Am9080 on FPGA and DOOM Application (UCF ECE Senior Design, sponsored by AMD).
Recreate the Am9080 (Intel 8080 clone) in Verilog on a Nexys A7 (Artix-7) FPGA, add 4 MB of bank-switched memory, VGA output, keyboard/mouse input, and a Turbo Mode, then run a DOOM-style raycasting game written in C (bare metal, fixed-point math).

**Team:** Fabian Nunez (user), Jereme Crump, Daniel Evans, Abram Tadros – all Computer Engineering.

## Files in this folder
- `Midterm Report.pdf` – the current, incomplete group report. Read it with `pdftotext -layout` (poppler's `pdftotext` is installed; `pdftoppm` is not, so the figures can't be rendered).
- `Midterm Report Planning.txt` – the group's agreed outline for each chapter, with page targets.
- `am9080-fpga-main/` – the group's GitHub repo:
  - `rtl/` – Verilog modules. Most are still empty stubs. `am9080_top.v` uses `{ }` instead of `( )` for its port list, so it won't compile yet. The accumulator, temp and instruction registers are missing reset logic.
  - `documentation/` – the project brief PDF, the Am9080 machine cycles/T-states PDF, and `reference_list.txt` (the core block diagram is on page 94 of the AMD 8080A/9080A handbook).

## How the user wants help
- **The user's assignment is Chapter 6 (Hardware Design).** They write the report text in their own words. Claude gives ideas, outlines and example drafts for inspiration.
- **Match the report's existing wording and tone:** "we"/"our team," plain explanations, bracketed references like `[Am9080A datasheet]`. Don't bring in a different writing style.
- **Don't copy the teammates' deep heading numbering** (e.g. 3.3.3.4). Use at most two levels (6.2, 6.2.1). The user plans to raise consolidating headings with the group.
- Number figures and tables in order across the whole report (Figure 1, Table 1…), with the caption centered above the figure or table, as the report already does. Don't name them by section number.
- Keep Chapter 6 to *how it was built* (architecture, math, logic, the need behind each module). The comparisons and "why we chose X" go in Chapter 3, the constraints in Chapter 4 and the risks in Chapter 8; Chapter 6 should only point back to those chapters.
- Don't say the group "chose" multi-cycle over pipelined. Matching the original Am9080 is the whole project, so phrase it as the design replicating the original behavior.

## Chapter 6 plan (15–20 pages)
- **6.1 Hardware Design Overview**: Go through Figure 2 (Hardware Design Diagram) and map each block to its RTL module(s) and owner.
- **6.2 Am9080 Core**: How the CPU is split into RTL modules that follow the handbook block diagram.
  - 6.2.1 Register Array: B, C, D, E, H, L, SP, PC; loading, incrementing, register pairs.
  - 6.2.2 Arithmetic Logic Unit: ALU operations, accumulator and temp registers, how the S/Z/AC/P/CY flags are calculated.
  - 6.2.3 Instruction Register & Decoder: fetching, storing and decoding an opcode into control signals.
  - 6.2.4 Timing & Control: M-cycle/T-state state machine, status byte during SYNC, HOLD/INT/READY.
  - 6.2.5 Address & Data Bus Interface: buffers and latches, why the data bus is split into data_in/data_out inside the FPGA.
- **6.3 Bank Switching Logic**: Extending the 16-bit address space to 4 MB.
  - 6.3.1 Memory Map: resident BRAM, memory-mapped I/O, framebuffer, 16 KB bank window.
  - 6.3.2 Bank Select Register & Address Decoding: 8-bit OUT port, {bank[7:0], A13–A0} = 22-bit physical address.
- **6.4 Memory Controller**: Write last, after the group decides between DDR2 and HyperRAM.
  - 6.4.1 Memory Interface: address/data/handshake signals between the bank logic and the controller.
  - 6.4.2 DDR2/HyperRAM Controller: rename once the group decides.
  - 6.4.3 READY & WAIT State Handling: latency → wait states, compared to the 20% stall spec.
- **6.5 VGA Display**: The path from software to the screen.
  - 6.5.1 Framebuffer: location, size and bits per pixel, dual-port BRAM.
  - 6.5.2 VGA Timing Controller: 640×480 @ 60 Hz, 25 MHz pixel clock, 800×525 total timing.
  - 6.5.3 Resolution Scaling & Grayscale Output: 160×120 scaled up 4x, R=G=B on the 12-bit VGA port.
- **6.6 Keyboard & Mouse I/O**
  - 6.6.1 PS/2 Receiver: the Nexys A7's PIC24 converts USB to PS/2; 11-bit frame, parity check.
  - 6.6.2 Keyboard & Mouse Input: scan codes and mouse packets → game input.
  - 6.6.3 I/O Port Map: table of port addresses.
- **6.7 Turbo Mode**
  - 6.7.1 Clock Generation: clock-enable dividers from 100 MHz (÷50 = 2 MHz, ÷25 = 4 MHz).
  - 6.7.2 Turbo Mode Selection: switch → `turbo` input; effects on memory timing and VGA.
- **6.8 Hardware Design Summary**

Suggested writing order: 6.1 → 6.3 → 6.7/6.5 → 6.2 subsections (as the RTL gets written) → 6.6 → 6.4.

## Progress on 6.2 Am9080 Core (top-level section)
For now, 6.2 contains: paragraph 1 → Figure 5 → paragraph 2 → paragraph 3 → Table 5.

**Paragraph 1 (the user's own version, minor fixes suggested):** introduces the core as the central component and cites the handbook block diagram "shown in Figure 5" in the second sentence, then explains why each block is a separate Verilog module (it's organized and each module can be unit tested before top-level integration). The old last sentence "Figure 5 shows how these modules are connected" was removed, because Figure 5 is now the handbook diagram.

**Figure 5. Am9080 Internal Block Diagram** [AMD 8080A/9080A Handbook, p. 94]. A cropped high-resolution screenshot of the handbook diagram, caption above. Check whether p. 94 is the PDF page or the printed page.

**Paragraph 2 (drafted):**
> Like the original processor, our core is an 8-bit CPU with an 8-bit data bus and a 16-bit address bus, giving it a 64 KB address space. The core contains six 8-bit general-purpose registers (B, C, D, E, H, and L) that can be paired into 16-bit registers, an 8-bit accumulator, a 16-bit stack pointer, and a 16-bit program counter. The original Am9080 executes instructions using a multi-cycle design, where each instruction is broken into one to five machine cycles and each machine cycle is broken into three to five clock periods called T-states. As a result, instructions take anywhere from 4 to 18 clock cycles to complete, as shown in the CPU Cycles Per Instruction specification in Table 1. Our design replicates this multi-cycle behavior so that the recreated core matches the original instruction timing of the Am9080.

**Paragraph 3 (drafted):**
> To implement this architecture in RTL, each block in Figure 5 is written as one or more Verilog modules. Table 5 lists each of these modules along with the block it belongs to and its role in the core. Sections 6.2.1 through 6.2.5 explain the architecture and logic behind each block in more detail.

**Table 5. Am9080 Core RTL Modules**
| Block | RTL Module(s) | Function |
|---|---|---|
| Register Array | `register_array`, `program_counter`, `stack_pointer`, `select_logic` | Stores the general-purpose registers, PC, and SP |
| Arithmetic Logic Unit | `alu`, `accumulator`, `temp_register`, `flag_register` | Performs arithmetic and logic operations and updates the status flags |
| Instruction Register & Decoder | `instruction_register`, `instruction_decoder` | Stores the current opcode and produces control signals |
| Timing & Control | `timing_control` | Steps through machine cycles and T-states and handles HOLD, INT, and READY |
| Address & Data Bus Interface | `address_buffer`, `address_latch`, `data_bus_buffer`, `data_latch` | Connects the core to the external address and data buses |

**Next up:** 6.2.1–6.2.5, or the other top-level sections.

## Open issues to raise with the group
- DDR2 vs. HyperRAM: the BOM lists a HyperRAM Pmod, but Table 2 and the Table 1 justifications assume DDR2. This blocks 6.4 and the latency numbers.
- Memory goal: 2.2.1 says 1 MB is a Basic Goal and 4 MB an Advanced Goal, but elsewhere 4 MB is the target.
- Figure and table numbering is out of order: Tables 3 and 4.x (Chapter 11) come after Table 5 in the document. Renumber in page order before submission, and update the Appendices list in the table of contents.
- Consolidate the deep heading numbering (e.g. 3.3.3.4).
