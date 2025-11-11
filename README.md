# 🧮 FPGA-Based Graphing Calculator  
**EE2026 Digital Design**  

### 👥 Team Members  
**Andrew, Michael, Joshua, Foo Kang**  
---

## 🚀 Project Overview  
An **FPGA-based graphic calculator** built on the **Basys3 board** with **two OLED displays** and **a mouse interface**.  
It supports **function plotting (linear, quadratic, logarithmic)** and **basic arithmetic operations** through FSM-based input control.

### **Main Features**
- 🧭 **Dual Mode System**  
  - **Calculator Mode:** Mouse-driven input for digits and operators; results displayed on 7-segment display.  
  - **Graph Mode:** Coefficients (`a`, `b`, `c`) adjustable via switches and buttons; real-time graph rendering.  
- 🎛️ **User Interaction:** Debounced button presses, FSM-controlled coefficient entry, cursor navigation, and dynamic OLED UI.  
- 🧮 **Computation:** Arithmetic via full ripple adder, shift-add multiplication, and manual 2’s complement subtraction.  
- 📉 **Graph Functions:** Supports panning (±x, ±y), axis rendering, and real-time coefficient display.  

---

## 🧩 Key Technical Components

| Student | Focus Area | Description |
|----------|-------------|-------------|
| **Andrew** | Coefficient input & graph UI | FSM for coefficient entry; OLED UI displaying selected function and coefficients; dynamic updates via switches & buttons. |
| **Michael** | Graph panning | Implemented panning using directional buttons; real-time feedback on 7-segment display with debounced inputs. |
| **Joshua** | Calculator UI | Mouse-driven calculator interface (0–9, +, −, ×, ÷, =, C); FSM for UI and visual feedback on OLED. |
| **Foo Kang** | Backend logic & integration | Arithmetic logic (ripple adder, shift-add mult/div), graph rendering, axis drawing, and mouse input constraint logic. |

---

## 🧠 Tools & Implementation
- **Language:** Verilog (Vivado)  
- **Hardware:** Basys3 FPGA, dual OLED displays, 7-segment display, mouse  
- **Support Tools:** Python (Pillow) for UI text rendering to Verilog pixel maps  

---

## ⚙️ Sample Outputs
- **Main Menu UI:** Mode selection between Calculator and Graph  
- **Graph Display:** Quadratic, Linear, and Logarithmic functions  
- **Calculator UI:** Mouse-driven number and operator input  

---

📸 *Developed as part of NUS EE2026 Digital Design, Semester 1 AY25/26.*

Link to our report can be found here:
https://docs.google.com/document/d/1dXBeARkXu-spr8omnYQ39wUORepX-4e9pMFNnWqBIgk/edit?tab=t.0
