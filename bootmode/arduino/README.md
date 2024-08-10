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
