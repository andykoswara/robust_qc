# RobustQC
MATLAB codes to determine the robustness of quantum control systems as described in https://doi.org/10.1103/PhysRevA.90.043414. 

The robust_amplitude_main.m file performs all the robustness calculations associated with the paper. It calls the input file containing parameters of the control field and various functions defined within the folder in order to generate outputs and their corresponding plots in the article.

Specific details worth mentioning for clarity are as follows:

The following figure 2 can be obtained by running the robust_amplitude_main.m file at different sigmas and collecting the values of E[P_41] and E[interference] for plotting purposes. Note that the sigma (stdev) parameter is set in the input file “robust_calc_test_mod_field_[ind].mat” and this can be overwritten in the main file at the desired sigma values.

![](Images/robust_calc_test_mod_diffields_Pji_and_interf.jpg)

The functions called in the main files have been updated with the latest descriptions, including its input, output and function definitions.

Note that the interference plot generated by the file now includes the pathway interferences within the same order $m$, which is not the case in the submitted papers, i.e. Figure 3 below only takes into account interferences between pathways of different orders.

![](Images/robust_calc_test_mod_field_1_interfnom_vs_interfexp.jpg)

In addition, the file includes calculations of data concerning:

1. The upper bounds of the terms C_ji^m, U_ji^m and P_ji^m
2. Display of numerical interference data,
3. Display of the significant encoded pathways, and 
4. The difference between moment- and sampled-calculations.

The files containing the control field parameters are given in the format “robust_calc_test_mod_field_[ind].mat”, where [ind] corresponds to indices of the field listed in Table II. Note that many of the examples uses input file with ind=1 and 8.

![](Images/robust_calc_test_mod_diffields_nonunisigma_pjiexp_interfexp.jpg)

The figure 5 above can be obtained in the same way as the previous figure but, in this case, only the sigma of the second amplitude mode is varied while the other is kept at 0.3 as noted in the article.

The results of the robustness analysis obtained from running robust_amplitude_main.m file is called by poptransfer.m file to generate plot of control field and population transfer corresponding to the figure 6 below.

![](Images/Robust_calc_test_mod_field_1_vs_8_field_poptranfer_sigma0pt675.jpg)

Table 4 in the paper corresponds to output values of the robust_amplitude_main.m file, which are also displayed at the end of each run which respect to an instance of sigma.

![](Images/Table4.png)
