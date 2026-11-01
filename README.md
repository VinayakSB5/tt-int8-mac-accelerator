# Pipelined INT8 Multiply-Accumulate (MAC) Hardware Accelerator

![gds](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/gds.yaml/badge.svg)
![test](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/test.yaml/badge.svg)
![docs](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/docs.yaml/badge.svg)

**Author:** Vinayak S Biradar  
**Target Process:** SkyWater 130nm (SKY130) Standard Cell ASIC Flow  
**Framework:** Tiny Tapeout Shuttle  
**Interactive 3D Layout Viewer:** [https://vinayaksb5.github.io/tt-int8-mac-accelerator/](https://vinayaksb5.github.io/tt-int8-mac-accelerator/)

---

## 1. Architectural Overview

This design is a synthesizable, 3-stage pipelined **INT8 Multiply-Accumulate (MAC) execution unit** targeted at low-power edge AI inference and matrix arithmetic acceleration. It is engineered for low latency, deterministic execution, and seamless integration as an execution unit alongside 32-bit RISC-V compute pipelines.

### Key Hardware Specifications
* **Data Precision:** Signed 8-bit operands with signed 16-bit intermediate multiplication.
* **Accumulator Depth:** 32-bit signed accumulation register to prevent arithmetic overflow during deep layer iterations.
* **Pipeline Latency:** 3 clock cycles from operand presentation to internal accumulation update.
* **Clock Frequency:** Verified for timing closure at $50\text{ MHz}$ ($T_{clk} = 20\text{ ns}$) under nominal PVT conditions.
* **Silicon Target:** Hardened into a standardized $1 \times 1$ Tiny Tapeout tile using OpenLane and the SkyWater 130nm PDK.

---

## 2. Microarchitecture & Pipeline Stages

The hardware splits computation across three registered stages to minimize critical path delays:
