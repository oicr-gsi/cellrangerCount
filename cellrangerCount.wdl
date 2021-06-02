version 1.0

workflow cellrangerCount {
  input {
    String runID
    String samplePrefix
    Array[File] fastqs
    String transcriptomeDirectory
  }

  call symlinkFastqs {
      input:
        samplePrefix = samplePrefix,
        fastqs = fastqs
    }

  call count {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = symlinkFastqs.fastqDirectory,
      transcriptomeDirectory = transcriptomeDirectory
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
    fastqDirectory: "Path to folder containing symlinked fastq files."
    transcriptomeDirectory: "Path to Cell Ranger compatible transcriptome reference."
    localMem: "Restricts cellranger to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger will use 90% of the memory available on your system."
  }

  meta {
    author: "Lawrence Heisler"
    email: "Lawrence.Heisler@oicr.on.ca"
    description: "Workflow for generating single cell feature counts for a single library."
    dependencies: []
  }
}

task symlinkFastqs {
  input {
    Array[File] fastqs
    String? samplePrefix
    Int mem = 1
  }

  command <<<
    mkdir ~{samplePrefix}
    while read line ; do
      ln -s $line ~{samplePrefix}/$(basename $line)
    done < ~{write_lines(fastqs)}
    echo $PWD/~{samplePrefix}
  >>>

  runtime {
    memory: "~{mem} GB"
  }

  output {
     String fastqDirectory = read_string(stdout())
  }

  parameter_meta {
    fastqs: "Array of input fastqs."
  }

  meta {
    output_meta: {
      fastqDirectory: "Path to folder containing symlinked fastq files."
    }
  }
}

task count {
  input {
    String modules = "cellranger/3.1.0"
    String runID
    String samplePrefix
    String fastqDirectory
    String transcriptomeDirectory
    Int threads = 4
    Int localMem = 64
    Int timeout = 24
  }

  command <<<
    set -euo pipefail

    cellranger count \
    --id "~{runID}" \
    --fastqs "~{fastqDirectory}" \
    --sample "~{samplePrefix}" \
    --transcriptome "~{transcriptomeDirectory}" \
    --localmem "~{localMem}"

    # compress folders
    tar cf - \
    ~{runID}/outs/filtered_feature_bc_matrix \
    ~{runID}/outs/raw_feature_bc_matrix | gzip --no-name > feature_bc_matrix.tar.gz

    tar cf - ~{runID}/outs/analysis | gzip --no-name > analysis.tar.gz

    tar cf - \
    ~{runID}/outs/raw_feature_bc_matrix.h5 \
    ~{runID}/outs/filtered_feature_bc_matrix.h5 \
    ~{runID}/outs/molecule_info.h5 | gzip --no-name > gene_matrices_molecule_info_h5.tar.gz
  >>>

  runtime {
    cpu: "~{threads}"
    memory: "~{localMem} GB"
    modules: "~{modules}"
    timeout: "~{timeout}"
  }

  output {
    File possortedGenomeBam = "~{runID}/outs/possorted_genome_bam.bam"
    File possortedGenomeBamIndex = "~{runID}/outs/possorted_genome_bam.bam.bai"
    File cloupe = "~{runID}/outs/cloupe.cloupe"
    File metricsSummary = "~{runID}/outs/metrics_summary.csv"
    File featureBcMatrix = "feature_bc_matrix.tar.gz"
    File analysis = "analysis.tar.gz"
    File geneMatricesMoleculeInfoH5 = "gene_matrices_molecule_info_h5.tar.gz"
  }

  parameter_meta {
    runID: "A unique run ID string."
    samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
    fastqDirectory: "Path to folder containing symlinked fastq files."
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
