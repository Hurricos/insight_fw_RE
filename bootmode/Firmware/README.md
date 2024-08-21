# Software

## Commands
4-byte frames are sent to the flasher.

- b{0,1}[15:0]: target argument based on command
  - (S): target address
  - (P): nil
  - (R): nil
  - (W): target address word content
  - (C): length of address range. Number includes the final byte. BE, obviously, so e.g. 0x01 0x00 is 256 bytes, whereas 0x00 0x00 "does nothing".

- b2[7:5]: command
  - 0x0: (X) no-op for resetting command stream. If H8 target misses a byte and becomes unaligned, you can send up to QTY4 of these one at a time and wait for a bad checksum.
  - 0x1: (S) seek to address, obligatorily word-aligned
  - 0x2: (P) show current address
  - 0x3: (R) read word at current address, and advance one word
  - 0x4: (W) write and verify word at current address, and advance one word
  - 0x5: (C) read checksum over address range

- b2[4:1]: default 0b0000; reserved for now for extra bits for future command variants.

- b2[0]: stuff bit, used to ensure checksum is always odd, EXCEPT when sending 0x0 to reset the command bytestream.

- b3[7:0]: frame checksum. ~~If checksum would have been 0x00, send 0x01.~~

## Responses
.. Always ends with a one-byte checksum.

For X, W: format is two-bytes total:
- b0 is status:
  - 0b00000000 if OK,
  - 0b00000001 if whole No-op command received (0x00 0x00 0x00 0x00),
  - 0b01010101 if RX checksum error,
  - 0b11111111 if Not OK.
- b1 is response frame checksum.

For R: format is three-bytes total:
- b0 is MSB content, b1 is LSB word content.
- b2 is frame checksum.

For C: format is three-bytes total:
- b0 and b1 are MSB and LSB of two-byte additive checksum of memory range, respectively.
- b2 is frame checksum.

For P: format is three-bytes total:
- b0 and b1 are MSB and LSB of current address, respectively.
- b2 is frame checksum.

For S: format is three-bytes total:
- b0 and b1 are MSB and LSB of moved-to address, respectively.
- b2 is frame checksum.
- S is handled more carefully, as seeking to the wrong address and tripping over an unintentionally-correct checksum is not something we can ever afford.

# Hardware

## Hardware on BCM and MCM

### CN3 - Debug connector
- [x] GND: CN3@5 (MCM@A24(LG1)) https://www.insightcentral.net/posts/1533658/
- Serial: https://www.insightcentral.net/threads/dumping-reverse-engineering-insight-g1-bcm-and-mcm-firmare.130914/page-5?post_id=1533658#post-1533658
  - [x] TX: CN3@4 (H8@103(RXD1)), https://www.insightcentral.net/posts/1533431/
  - [x] RX: CN3@10 (H8@102(TXD1))
- [x] VBU: MCM@B10 (and nowhere else)
  - Needed as backup voltage for integrated watchdog to work: https://www.insightcentral.net/posts/1533785/
- [ ] LAT: CN3@9 https://www.insightcentral.net/posts/1533658/
  - [x] Cannot verify -- must do so experimentally as I don't remember the exact latch circuit
- [x] VCC: CN3@3 (IC22 (MCM) or IC3 (BCM)) VCC in: https://www.insightcentral.net/threads/dumping-reverse-engineering-insight-g1-bcm-and-mcm-firmare.130914/page-5?post_id=1534290#post-1534290
- [x] VPP: CN3@8 https://www.insightcentral.net/posts/1534290/
- [x] MD2: CN3@2
  - https://www.insightcentral.net/threads/dumping-reverse-engineering-insight-g1-bcm-and-mcm-firmare.130914/page-4?post_id=1533431#post-1533431
