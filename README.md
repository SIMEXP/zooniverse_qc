<p align="center">
   <strong> Visual Assessment of Brain Registration Quality in Functional MRI studies </strong>
</p>

### Overview
Several measures and tools have been proposed to asses quality control (QC) of functional magnetic resonance imaging (fMRI) data, most of them focus on the quality of raw data images out of the scanner (see Liu TT (2015) for a review). Very few of them focus on the QC of  preprocessed fMRI data which are highly impacted by the typical image preprocessing steps (brain extraction and coregistration).

Studies that addresses QC of preprocessed data are divided in two categories;  Manual QC and automated QC. This document describe the major steps to  go through to manual QC of fMRI preprocessed data

### Quality control of preprocessed images
#### General Status

For overall QC **Status** three values are acceptable:
- **Fail:**  A major flaw has been identified. Typically misregistration, artefacts or deformation.

- **Maybe:**  A minor problem has been identified, sometimes with the pipeline itself or in the raw data. Most common are brain extraction (BET) for structural images, Misregistration (MR) and misplaced field of view  for functional images (FOV). Other less common causes of maybe are Brain Deformation (DEF), Brain Abnormality (ABN), Ghosthing (GHO), Motion artifacts (MOT), and, in some cases, Arterial artefacts (ART). Extreme variants of these issues may qualify for a Fail.

- **OK:** Neither Fail nor Maybe. None or very minor MR, BET issues, and small FOV, DEF, ABN, GHO, MOT or ART.  Issues such as Signal Loss (SL), Ventricule mis alligned (VENT) or brain atrophy (ATR) can be listed with an OK status, as they cannot be corrected fully by registration. However, once flagged, these issues can be used to build confound regressors in group analysis. An acceptable FOV will depend on the target coverage of the study (e.g. if cerebellum is excluded by design, this should not be flagged by FOV). Similarly, at 3T, normal DEF and SL in the temporal and orbitofrontal cortices will not be flagged, as they are observed systematically (unless a B0 field correction is implemented in the pipeline).   

#### T1 normalisation
#### *Brain segmentation - Spatial normalisation*
![](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/fig_qc_t1.png?raw=true)

The anatomical landmarks that should be well aligned in a successful coregistration include: central sulcus (**A**), cingulate sulcus (**B**), parieto-occipital fissure (**C**), calcarine fissure (**D**), tentorium cerebellum (**E**), the lateral ventricles (**F**), the outline of the brain (**G**) and the hippocampal formation (**H**) bilateraly. The landmarks are outlined on an individual brain after successful non-linear coregistration in stereotaxic space.

The most frequent issues related to brain segmentation and spatial normalisation are listed below with figures for each Fail / Maybe / OK cases.

#### **MR** Misregistration between the T1/template

#####  [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010032.html)


![Epic Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_MR_fail/summary_X_0010032_anat2template_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0021005.html)
![maybe case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_MR_maybe/summary_X_0021005_anat2template_target.gif?raw=true)

#####  [OK Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X0021005.html)
![OK case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_MR_ok/summary_X_0021041_anat2template_target.gif?raw=true)

#### **BET** problem with brain extraction.

#####  [Failed Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X3699991.html)


![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_BET_fail/summary_X_3699991_anat2template_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010042.html)
![maybe case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_BET_maybe/summary_X_0010042_anat2template_target.gif?raw=true)

#####  [OK Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X1988015.html)
![OK case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_BET_OK/summary_X_1988015_anat2template_target.gif?raw=true)


#### **ART**    miscellaneous types of artefacts.

#####  [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010013.html)


![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_ART_fail/summary_X_0010013_anat2template_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X2026113.html)
![maybe case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_ART_maybe/summary_X_2026113_anat2template_target.gif?raw=true)

#####  [OK Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0021043.html)
![OK case](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_ART_OK/summary_X_0021043_anat2template_target.gif?raw=true)


#### **MOT** Motion artefacts.

#####  [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010003.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_MOT_fail/summary_X_0010003_anat2template_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X1696588.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_MOT_maybe/summary_X_1696588_anat2template_target.gif?raw=true)


#### **FOV** Incomplete field of view.

##### [Failed Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X2854839.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_FOV_fail/summary_X_2854839_anat2template_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X2907383.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_FOV_maybe/summary_X_2907383_anat2template_target.gif?raw=true)


#### **GHO** Ghosting.

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X3515506.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_GHO_maybe/summary_X_3515506_anat2template_target.gif?raw=true)


#### **ATR** General brain atrophy.

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X3163200.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_anat_ATR_maybe/summary_X_3163200_anat2template_target.gif?raw=true)



#### T2* normalisation
#### *Brain segmentation - Spatial normalisation*
![](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/fig_qc_t2.png?raw=true)

The anatomical landmarks that should be well aligned in a successful coregistration include: central sulcus (**A**), cingulate sulcus (**B**), parieto-occipital fissure (**C**), calcarine fissure (**D**), tentorium cerebellum (**E**), the lateral ventricles (**F**), the hippocampal formation (**H**) and the outline of the brain (**G**) bilateraly. The landmarks are outlined on an individual brain after successful non-linear coregistration in stereotaxic space.

#### **MR** Misregistration between the T1/T2*.

##### [Failed Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X0026030.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_MR_fail/summary_X_0026030_func2anat_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X0010002.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_MR_maybe/summary_X_0010002_func2anat_target.gif?raw=true)

#####  [OK Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010054.html)

![ OK](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_MR_OK/summary_X_0010054_func2anat_target.gif?raw=true)

#### **FOV** Incomplete field of view.

##### [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0026043.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_FOV_fail/summary_X_0026043_func2anat_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0026005.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_FOV_maybe/summary_X_0026005_func2anat_target.gif?raw=true)

#### **ABN**  Brain abnormality.

##### [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0026043.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_ABN_fail/summary_X_0016017_func2anat_target.gif?raw=true)

#### **SL** Signal loss.

##### [Failed Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X0010023.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_SL_fail/summary_X_0010023_func2anat_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_niak/wrapper_X1201251.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_SL_maybe/summary_X_1201251_func2anat_target.gif?raw=true)


#### **DEF** Non-linear deformations between the anat and the func..

##### [Failed Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X8218392.html)

![ Fail](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_DEF_fail/summary_X_8218392_func2anat_target.gif?raw=true)

#####  [Maybe Case](http://simexp.github.io/adhd200_qc_athena/wrapper_X0026016.html)

![ Maybe](https://github.com/SIMEXP/zooniverse_qc/blob/master/qc_manual/Fig_func_DEF_maybe/summary_X_0026016_func2anat_target.gif?raw=true)
