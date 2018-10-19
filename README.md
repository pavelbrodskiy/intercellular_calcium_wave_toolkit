# Overview
This toolbox simplifies spatial analysis of calcium wave dynamics in the developing wing disc. To understand why this is useful, it may be helpful to read our manuscript [here](https://doi.org/10.1101/104745). This repo contains a demo of the toolbox's functionality. The file demo.pdf serves as a test for much of the toolbox's functionality.

# Contact
- The most current public manuscript is a bioRxiv preprint located [here](https://doi.org/10.1101/104745). Feel free to cite it if you find this toolbox useful.
- The corresponding author is Jeremiah J. Zartman, whose contact information is in the preprint
- Feel free to contact me regarding the toolbox at pavelbrodskiy@gmail.com

# Requirements
- MATLAB 2017b or newer is required
- The following toolboxes are required to use the functionality described in the demo
  - Image processing toolbox
  - Statistics and machine learning toolbox
- The following toolboxes are required for additional features of the toolbox
  - Signal processing toolbox
  - Parallel computing toolbox
  - Wavelet toolbox
  - Global optimization toolbox
- You need either your own confocal time-lapse data to analyze, or to obtain the test data. The test data is not publically available as the manuscript is still undergoing peer review.

# Steps for running the demos
- Clone the repository to get the code
- Obtain the raw data for samples in demo and place it in the Data folder. Contact me to obtain this.
- Obtain the "processed" data and place it in the dataProcessing folder. Contact me to obtain this.
- Run the file demo_part_1.mlx, clicking "yes" when asked to change the current folder. This requires the raw data.
- Run the file demo_part_2.mlx, clicking "yes" when asked to change the current folder. This requires the processed data.

# Toolbox organization
- **Root directory scripts.** The toolbox is used by the generation of scripts. The demo shows how this is done. Ideally, each figure is generated by one script and that script is saved with the figure so the figure can always be regenerated. There is also the getSettings function that allows users to change the way analysis is done, and prepareWorkspace that initializes the toolbox. The first lines in a script using this toolbox should be:
```
settings = prepareWorkspace()
```
- **Modules.** Toolbox functions. This is the meat of where the processing workflows are.
- **Dependencies.** Third-party dependencies used by this package. This does not include necessary toolboxes.
- **Data.** Folder for raw data. This is optional once it has been preprocessed and stored in the dataProcessing folder
- **dataProcessing.** Folder for preprocessed data. Each step of the analysis is exported here to prevent repeated manual annotation and computations. Updating manual annotations and redoing computations (such as when additional features are added to the statistical analysis) requires manual removal of the relelvant files/folders at this time. This software will run without this folder and generate it from scratch if the relevant Data is in the Data folder.
- **Inputs.** This is the required metadata. Each experiment must be documented here. There is currently no automated way to sense new data in the data folder. We keep track of experiments in labelTabel.xlsx, the laser power used in laserpower.csv, data that is unusable is added to labelReject.xlsx, and flipAPDV.xlsx keeps track of the orientation of samples. Lines must currently be added to flipAPDV in order to process new data.

# References
This is an annotated list of published papers and preprints providing context for or stemming from this work.

An introduction to the role of calcium signaling in developmental contexts

> Brodskiy, P.A. and Zartman, J.J., 2018. Calcium as a signal integrator in developing epithelial tissues. *Physical biology*, 15(5), p.051001. DOI: [10.1088/1478-3975/aabb18](https://doi.org/10.1088/1478-3975/aabb18).

An initial look at calcium signaling dynamics in wing development

> Narciso, C., Wu, Q., Brodskiy, P., Garston, G., Baker, R., Fletcher, A. and Zartman, J., 2015. Patterning of wound-induced intercellular Ca<sub>2+</sub> flashes in a developing epithelium. *Physical biology*, 12(5), p.056005. DOI: [10.1088/1478-3975/12/5/056005](https://doi.org/10.1088/1478-3975/12/5/056005).

A charactarization of the role of calcium signaling in wing development

> Wu, Q.\*, Brodskiy, P.A.\*, Huizar, F.J., Jangula, J.J., Narciso, C., Levis, M.K., Brito-Robinson, T. and Zartman, J.J., 2017. In vivo relevance of intercellular calcium signaling in Drosophila wing development. *bioRxiv*, p.187401. DOI: [10.1101/187401](https://doi.org/10.1101/187401).

A charactarization of the calcium signaling regulation by morphogens.

> Brodskiy, P.A.\*, Wu, Q.\*, Huizar, F.J., Soundarrajan, D.K., Narciso, C., Levis, M., Arredondo-Walsh, N., Chen, J., Liang, P., Chen, D.Z. and Zartman, J.J., 2017. Intercellular calcium signaling is regulated by morphogens during Drosophila wing development. *bioRxiv*, p.104745. DOI: [10.1101/104745](https://doi.org/10.1101/104745).

\* indicates these authors contributed equally.
