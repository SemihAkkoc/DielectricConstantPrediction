# Dielectric Constant Prediction

This project is an implementation of Isaac Waldron’s “Suspended Ring Resonator for Dielectric Constant Measurement of Foams” master thesis.

## Branches
The code contains two main branches:
1. **MATLAB Simulation Part**: Models and coefficients are generated according to Waldron’s paper.
2. **CST Simulation Part**: Models and coefficients are generated according to CST Studio simulations.

## Common Functions
These functions are used in both parts:
- `PeakFinder`
- `PeakFinder_v2`
- `QFactorFinder`
- `QFactorFinder_v2`
- `QFactorFinder_v3`
- `ReadCoeffs`
- `ReadCoeffs_v2`
- `ReadCoeffs_v3`
- `ReadTouchstone`

## Running CST Simulation
To run the CST simulation results, execute the `main.m` code. Before running, change the following parameters:
- Uncomment the `Compare_v3` part.
- Modify the `ref_filename` if needed (for different thicknesses, change the reference file, e.g., for air between the plates, use `eps_r=1` and `tanD=0`).
- Adjust the `comp_filename` to specify the Touchstone files to be compared.
- Set the `coeff_filename` to specify the model coefficients file. Keep `cst_coeff.mat` unchanged for CST simulation models.
- Modify the `order` parameter for polynomial fits (do not use less than 3rd order).

## Running MATLAB Simulation
To run MATLAB simulation results, execute the `main.m` code. Adjust these parameters:
- Uncomment the `Compare_v2` part.
- Modify the `ref_filename` for different thicknesses.
- Set the `comp_filename` to specify the Touchstone files to be compared.
- Adjust the `coeff_filename` to specify the model coefficients file.
- Modify the `order` parameter (use at least 3rd order polynomials).

## Generating S21 Parameters using Waldron’s Design
To modify setup parameters such as the thickness of the material, dielectric constant, etc., navigate to the `MATLAB_simulation/SuspendedRingResonator` folder and change:
- `eps_material` for the substrate’s dielectric constant.
- `tan_loss_material` for the substrate’s tangent loss.
- `t` for the sample layer thickness.
- `gap` for the air gap layer thickness.

### To generate S21 parameters:
1. Place the `MATLAB_simulation` folder in the same directory as `main.m`, or add it to the path.
2. In `main.m`, uncomment the model training part.
3. Change the `coeff_filename` to save polynomial fit coefficients.
4. Modify the following vectors:
   - `f_start_end_stepsize` for frequency range and resolution.
   - `eps_start_end_stepsize` for dielectric sweep range and resolution.
   - `tloss_start_end_stepsize` for tangent loss sweep range and resolution.
5. Set `doPlot` to `true` to plot graphs or `false` to skip plotting.

## Important Functions

### `CSTDataFit.m` (not a function, separate code)
**Description**:  
This code reads the CST simulation grid data and produces polynomial fit coefficients for fixed `eps_r` and tangent loss sweep and vice versa. The coefficients are saved in a file specified by `coeff_filename`.

**Input**:  
- The `ReadCSTData` function gets the CST simulation data filename as input. This part needs to be changed for different datasets.

**Output**:  
- None, but polynomial fit coefficients are saved.

---

### `function [S21q_ref, f_range] = CSTDataExtract(fixed_eps, order_till, doPlot)`
**Description**:  
This function finds S21 tangent loss sweep data for a given `eps_r` value and its frequency range. **Note**: Don't forget to change the `load` function parameters if the data changes.

**Inputs**:
- `fixed_eps`: The `eps_r` value for which the S21 tangent loss sweep is desired.
- `order_till`: Determines the order of polynomial fits that will be saved.
- `doPlot`: Boolean to toggle the S21 tangent loss sweep and Q factor shift plots on or off.

**Outputs**:
- `S21q_ref`: S21 tangent loss sweep data for the specified `eps_r` value.
- `f_range`: Frequency range of `S21q_ref`.

---

### `function [eps, tan_loss] = Compare(S21c_filename, S21r_filename, coeffs_filename, doPlot)`
**Description**:  
Compares a given Touchstone file with a reference file and returns the dielectric constant (`eps`) and tangent loss values.

**Inputs**:
- `S21c_filename`: The Touchstone filename of the compared data.
- `S21r_filename`: The Touchstone filename of the reference data.
- `coeffs_filename`: The `.mat` file with saved coefficients that the model will use.
- `doPlot`: Boolean to toggle plots on or off.

**Outputs**:
- `eps`: A 1x2 vector containing dielectric constant values for the first and second peaks.
- `tan_loss`: A 1x2 vector containing tangent loss values for the first and second peaks.

---

### `function [eps, tan_loss] = Compare_v2(S21c_filename, S21r_filename, coeffs_filename, order, doPlot)`
**Description**:  
Compares a given Touchstone file with a reference file, returning `eps` and tangent loss values. This version uses the polynomial order information to determine the values.

**Inputs**:
- `S21c_filename`: The Touchstone filename of the compared data.
- `S21r_filename`: The Touchstone filename of the reference data.
- `coeffs_filename`: The `.mat` file with saved coefficients.
- `order`: Sets which order of polynomial coefficients will be used.
- `doPlot`: Boolean to toggle plots on or off.

**Outputs**:
- `eps`: A 1x2 vector containing dielectric constant values for the first and second peaks.
- `tan_loss`: A 1x2 vector containing tangent loss values for the first and second peaks.

---

### `function [eps, tan_loss] = Compare_v3(S21c_filename, S21r_filename, coeffs_filename, order, doPlot)`
**Description**:  
Compares a given Touchstone file with a reference file, returning `eps` and tangent loss values. The difference from previous versions is that it adaptively finds the Q factor shift by using the `eps` value of the compared data as the reference for tangent loss.

**Inputs**:
- `S21c_filename`: The Touchstone filename of the compared data.
- `S21r_filename`: The Touchstone filename of the reference data.
- `coeffs_filename`: The `.mat` file with saved coefficients.
- `order`: Determines which polynomial coefficients to use.
- `doPlot`: Boolean to toggle plots on or off.

**Outputs**:
- `eps`: A 1x2 vector containing dielectric constant values for the first and second peaks.
- `tan_loss`: A 1x2 vector containing tangent loss values for the first and second peaks.

---

### `function [fr_1, fr_2, Q_fr_1, Q_fr_2] = Simulation_Plot(coeff_filename, f_start_end_stepsize, eps_start_end_stepsize, tloss_start_end_stepsize, doPlot)`
**Description**:  
This function generates S21 grid data based on Waldron’s analytic findings and saves it into `S21_course_grid.mat`. It also generates S21 data for a fixed tangent loss and epsilon sweep, and vice versa. The function returns 3rd order polynomial fit functions.

**Inputs**:
- `coeff_filename`: The `.mat` file containing the saved coefficients.
- `f_start_end_stepsize`: A 1x3 vector containing the start, end, and step size for the frequency.
- `eps_start_end_stepsize`: A 1x3 vector containing the start, end, and step size for the dielectric constant.
- `tloss_start_end_stepsize`: A 1x3 vector containing the start, end, and step size for the tangent loss.
- `doPlot`: Boolean to toggle plots on or off.

**Outputs**:
- `fr_1`: First resonance shift and `eps_r` function (takes frequency shift as input).
- `fr_2`: Second resonance shift and `eps_r` function (takes frequency shift as input).
- `Q_fr_1`: First peak Q factor shift and `eps_r` function (takes Q factor shift as input).
- `Q_fr_2`: Second peak Q factor shift and `eps_r` function (takes Q factor shift as input).

---

### `function [S21] = SuspendedRingResonator(f_range, eps_sample, tan_loss_sample)`
**Description**:  
Produces the S21 parameter according to the calculations laid out in Waldron’s thesis.

**Inputs**:
- `f_range`: The frequency range over which the S21 parameter will be generated.
- `eps_sample`: The sample's dielectric constant value.
- `tan_loss_sample`: The sample's tangent loss value.

**Output**:
- `S21`: The calculated S21 value based on Waldron’s thesis.

---

### `function [f_range, noisy_S21] = GenerateNoisyS21(filename, sigma)`
**Description**:  
This function adds additive Gaussian white noise with a specified variance to the S21 parameter saved in a Touchstone file.

**Inputs**:
- `filename`: The file containing the S21 data to which noise will be added.
- `sigma`: The variance of the Gaussian random variable used for adding noise.

**Outputs**:
- `f_range`: The frequency range of the noisy S21.
- `noisy_S21`: The S21 parameter with added Gaussian noise (mean=0, variance=sigma).

---

This repository contains the MATLAB and CST models required for dielectric constant and tangent loss prediction based on Waldron’s methodology additionally model trained on CST simulations.
