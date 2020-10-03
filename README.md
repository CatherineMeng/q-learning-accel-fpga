# q-learning-accel-fpga

This project implements the pipeline aaccelerator design for Q Learning as described in the paper:
```
@inproceedings{meng2020qtaccel,
  title={QTAccel: A Generic FPGA based Design for Q-Table based Reinforcement Learning Accelerators},
  author={Meng, Yuan and Kuppannagari, Sanmukh and Rajat, Rachit and Srivastava, Ajitesh and Kannan, Rajgopal and Prasanna, Viktor},
  booktitle={2020 IEEE International Parallel and Distributed Processing Symposium Workshops (IPDPSW)},
  pages={107--114},
  year={2020},
  organization={IEEE}
}
```
![alt text](https://github.com/CatherineMeng/q-learning-accel-fpga/blob/master/pipqrl.PNG)

# Running Procedure
Step1: Open vivado Design Suite, create new project.

Step2: Add design source files: pipeline.v, rtable.v, qmaxtable.v, qtable.v

Step 3: Add simulation source file: testbench.v

After done step 2 and 3 should see some architecture like this (files names might be different): ![alt text](https://github.com/CatherineMeng/q-learning-accel-fpga/blob/master/Screen%20Shot%202019-09-02%20at%202.20.06%20AM.png)



Step 4: Click run simulation on the left to run simulation. Once done, generate RTL design diagram

