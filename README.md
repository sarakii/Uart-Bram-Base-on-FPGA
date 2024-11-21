# 基于FPGA的一个简单的串口收发、Bram存取实验<br>
## 实现的功能<br>
使用串口助手向开发板发送16帧数据，开发板接收到16帧数据后把这些数据存进bram的0~15号内存中，存完以后将这些数据按顺序读取出来并发送到串口助手当中。<br>
![Snipaste_2024-11-21_14-45-23](https://github.com/user-attachments/assets/c8b5aada-3e05-45c2-9c19-107f5141bcf7)

## 实验截图<br>
### 向串口发送16帧数据，接收到相同的数据。<br>
![Snipaste_2024-11-20_20-06-51](https://github.com/user-attachments/assets/dffc7f21-ad0e-415a-900a-5b0d2ac992c7)<br>
### 以10ms为间隔，每帧发送16个数据，发送160次，共发送2560个数据，经检验，发送与接收数据一致，无错误。<br>
![Snipaste_2024-11-20_20-11-24](https://github.com/user-attachments/assets/134ddfcc-ef57-45fb-88af-617a24a165d6)
![Snipaste_2024-11-20_20-13-02](https://github.com/user-attachments/assets/14e0731b-ca61-4df0-9454-498297901aa3)
## 后续计划
1. 优化串口代码
2. 将串口代码写成状态机形式
