version 1.0

workflow cellranger_count {
  input {
    String runID
    String samplePrefix
    String fastqDirectory
    String transcriptomeDirectory
    String localMem
  }
  call count {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = fastqDirectory,
      transcriptomeDirectory = transcriptomeDirectory,
      localMem = localMem
  }

  output {
    File possortedGenomeBam = count.possortedGenomeBam
    File possortedGenomeBaiIndex = count.possortedGenomeBamIndex
    File cloupe = count.cloupe
    File metricsSummary = count.metricsSummary
    File featureBcMatrix = count.featureBcMatrix
    File analysis = count.analysis
    File geneMatricesMoleculeInfoH5 = count.geneMatricesMoleculeInfoH5
  }

  parameter_meta {
    runID: "A unique run ID string."
    samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
    fastqDirectory: "Path to folder containing fastq files."
    transcriptomeDirectory: "Path to Cell Ranger compatible transcriptome reference."
    localMem: "Restricts cellranger to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger will use 90% of the memory available on your system."
  }

  meta {
    author: "Lawrence Heisler"
    email: "Lawrence.Heisler@oicr.on.ca"
    description: "Workflow for generating single cell feature counts for a single library."
  }
}

task count {
  input {
    String? modules = "cellranger"
    String? cellranger = "cellranger"
    String runID
    String samplePrefix
    String fastqDirectory
    String transcriptomeDirectory
    String? localMem = "2"
  }

  command <<<
   ~{cellranger} count \
    --id "~{runID}" \
    --fastq "~{fastqDirectory}" \
    --sample "~{samplePrefix}" \
    --transcriptome "~{transcriptomeDirectory}" \
    --localmem "~{localMem}"

    # zip gene matrices
    zip -r feature_bc_matrix \
    outs/filtered_feature_bc_matrix \
    outs/raw_feature_bc_matrix

    # zip analysis folder
    zip analysis

    #zip h5 files
    zip gene_matrices_molecule_info_h5 \
    outs/raw_feature_bc_matrix.h5 \
    outs/filtered_feature_bc_matrix.h5 \
    outs/molecule_info.h5
  >>>

  runtime {
    memory: "~{localMem} GB"
    modules: "~{modules}"
  }

  output {
    File possortedGenomeBam = "outs/possorted_genome_bam.bam"
    File possortedGenomeBamIndex = "outs/possorted_genome_bam.bam.bai"
    File cloupe = "outs/cloupe.cloupe"
    File metricsSummary = "outs/metrics_summary.csv"
    File featureBcMatrix = "feature_bc_matrix.zip"
    File analysis = "analysis.zip"
    File geneMatricesMoleculeInfoH5 = "gene_matrices_molecule_info_h5.zip"
  }

  parameter_meta {
    runID: "A unique run ID string."
    samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
    fastqDirectory: "Path to folder containing fastq files."
    transcriptomeDirectory: "Path to Cell Ranger compatible transcriptome reference."
    localMem: "Restricts cellranger to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger will use 90% of the memory available on your system."
    modules: "Environment module name to load before command execution."
  }

  meta {
    output_meta: {
      possortedGenomeBam: "BAM file.",
      possortedGenomeBamIndex: "BAM index.",
      cloupe: "Loupe Cell Browser file.",
      metricsSummary: "Run summary CSV.",
      featureBcMatrix: "Raw and filtered feature-barcode matrices MEX.",
      analysis: "Secondary analysis output CSV.",
      geneMatricesMoleculeInfoH5: "Raw and filtered feature-barcode matrices HDF5 and per-molecule read information."
    }
  }
}