# annotation

This routine simplifies the implementation of the [CellTypist](https://www.celltypist.org/) automated annotation method. The process is written to allow for both stand-alone execution or integration as a module with the [coreSC](https://github.com/ChoBioLab/coreSC) Seurat workflow. 

While CellTypist can take both generic count matrices (Seurat) and AnnData objects, this approach has been written exclusively for Seurat input files. Since raw counts are used as inputs, it is not required that a fully processed object be used as input. Still, it is advised that any data set should be carried through a complete pre-processing workflow regardless for the sake of comprehensive validation. 

## Workflow
1. read RDS input object
1. extract raw counts as a sparse matrix
1. convert sparse matrix to full counts matrix
1. run CellTypist with majority voting
1. assign `predicted_labels.csv` values as metadata of input object
1. run `FindAllMarkers()` using `predicted_labels` as `Idents()`

## Setup

### Dependencies
- This method uses the [Singularity](https://docs.sylabs.io/guides/3.0/user-guide/installation.html) container execution framework.

### First Time
```sh
# clone the repo
git clone https://github.com/ChoBioLab/annotation.git
```

### Config
1. Select a trained model [REQUIRED]
    - https://www.celltypist.org/models | https://www.celltypist.org/organs
        - Gut: `Cells_Intestinal_Tract`, `Adult_Human_Intestine` (combined)
        - Immune: `Immune_All_High`, `Immune_All_Low`
        - Liver: `Adult_Human_Liver` (combined)
    - Determine the appropriate model for classification. Selecting a model that is not the correct fit will generate an annotation that is effectively worthless!
    - The appropriate model: 
        - Needs to have been trained using CellTypist's classification method
        - Will be a close match to your query data on a level of cell profile-likeness (e.g. organ system, disease state, etc)
        - Should have been developed with a comprehensive, diverse, well-annotated training set
    - Training custom models is an option but should only be undertaken with a complete knowledge of all factors involved.
1. Confirm parallel memory use with future [OPTIONAL]
    - The `-w WORKERS` and `-r RAM` args give number of threads, and RAM/thread. Each individual task needs an adequate threshold of RAM to complete its work. Also WORKERS * RAM gives the total memory allocation. This should live under the available system RAM for the job as a whole. If either of these considerations are not met, the run will fail!
    - The default values are 8 * 8 (8 workers and 8GB RAM/worker).

## Usage
- Execution can be carried out with the `run` script and the appropriate args.

`./run`
- `-i` *INPUT* [NULL]
- `-m` *MODEL* [NULL]
- `-w` *WORKERS* [8]
- `-r` *RAM* [8]

```sh
# example

cd annotation           # run should be executed from the repo path root
./run -i /path/to/object/pbmc.RDS -m Immune_All_High
```

### Output
```sh
output_2023-06-23_13.19.45/
├── annd_all_markers.csv            # output of FindAllMarkers for annotated obj
├── celltypist-log.txt              # process log
├── decision_matrix.csv             # CellTypist output
├── pbmc-annd_2023-06-23.RDS        # input obj annotated with predicted_labels.csv fields
├── predicted_labels.csv            # CellTypist output
└── probability_matrix.csv          # CellTypist output
```

### File Tree
```sh
annotation/
├── README.md
├── run                     # EXECUTION SCRIPT and main runtime
└── src
    ├── apply-ann.R         # application of predicted labels to input and find DEGs
    ├── getopts             # run script arguments
    └── matrix-convert.R    # routine to extract and prepare raw counts matrix
```
