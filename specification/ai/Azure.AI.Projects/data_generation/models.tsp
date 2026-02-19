import "@typespec/http";
import "@typespec/rest";
import "@azure-tools/typespec-autorest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";
import "../common/models.tsp";
import "../main.tsp";

using TypeSpec.Rest;
using TypeSpec.Versioning;

namespace Azure.AI.Projects;

@doc("Error information for a data generation job that failed.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationJobError {
  @doc("A machine-readable error code.")
  code?: string;

  @doc("A human-readable error message.")
  message?: string;
}

@doc("The supported data generation job types.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
union DataGenerationJobType {
  string,

  @doc("Question answers job type")
  QuestionAnswers: "QuestionAnswers",

  @doc("Multiple choice questions job type")
  MultipleChoiceQuestions: "MultipleChoiceQuestions",

  @doc("Question answers with tools job type")
  QuestionAnswersWithTools: "QuestionAnswersWithTools",
}

@doc("The supported output formats for generated data.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
union DataGenerationOutputFormat {
  string,

  @doc("Fine-tuning supervised training output format")
  FineTuneSupervised: "FineTuneSupervised",

  @doc("Fine-tuning reinforcement training output format")
  FineTuneReinforcement: "FineTuneReinforcement",

  @doc("Evaluation dataset output format")
  Evaluation: "Evaluation",
}

@doc("File types.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
union DataFileType {
  string,

  @doc("Azure OpenAI file.")
  file: "file",

  @doc("Foundry dataset.")
  dataset: "dataset",
}

@doc("A seed data source entry.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationSeedDataSource {
  @doc("The seed data source type.")
  type: DataFileType;

  @doc("The identifier of the file when type is 'file'.")
  file_id: string;
}

@doc("Common job options shared by all data generation job types.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationJobBaseOptions {
  @doc("Number of synthetic samples to generate.")
  num_samples: int32;

  @doc("Desired output format for generated data.")
  output_format: DataGenerationOutputFormat;

  @doc("Desired file type for any output file(s) produced. Either dataset or Azure OpenAI file. Defaults to file if not provided.")
  output_file_type?: DataFileType;

  @doc("Prefix applied to any output file(s) produced. Required if output_file_type is 'file'. Ignored if output_file_type is 'dataset'. Applicable only when output format is not 'Evaluation' since evaluation format creates dataset output files.")
  output_file_prefix?: string;

  @doc("Name of the output dataset to create. If not specified, a default name will be generated. Applicable only when output_file_type is 'Dataset'. If dataset with same name already exists then tries to create a new version of the dataset with the generated data.")
  // This is kind of duplicate of output_file_prefix should merge them as part of Api public preview review.
  output_dataset_name?: string;
}

union DataGenerationOutputFileType{
  string,

  @doc("Output file(s) is created as Azure OpenAI files")
  AzureOpenAIFile: "AzureOpenAIFile",

  @doc("Output file(s) is created as dataset asset file.")
  Dataset: "Dataset",
}

@doc("Options specific to evaluation data generation, applicable when output format is 'Evaluation'.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model EvaluationItemGenerationOptions {
  @doc("Prompt used by model for data generation.")
  prompt?: string;
  
  @doc("Optional agent name to use for data generation. Used for fetching agent metadata used for evaluation data generation.")
  agent_name?: string;

  @doc("Optional agent version to use for data generation. Used for fetching agent metadata used for evaluation data generation.")
  agent_version?: string;
}

@doc("Options specific to a QuestionAnswers data generation job.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model QuestionAnswersDataGenerationJobOptions extends DataGenerationJobBaseOptions {
  @doc("Number of conversational turns to simulate for each generated sample. Applicable only for fine-tuning output formats to create multi-turn dialogue samples.")
  num_turns?: int32;
  @doc("Data generation options specific to evaluation output format.")
  evaluation_item_generation_options?: EvaluationItemGenerationOptions;
}

@doc("Options specific to a MultipleChoiceQuestions data generation job.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model MultipleChoiceQuestionsDataGenerationJobOptions extends DataGenerationJobBaseOptions {
  @doc("Number of answer choices to generate per question.")
  num_choices?: int32;
}

@doc("Options specific to a QuestionAnswersWithTools data generation job.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model QuestionAnswersWithToolsDataGenerationJobOptions extends DataGenerationJobBaseOptions {
  @doc("Number of conversational turns to simulate for each generated sample (tool-augmented scenario).")
  num_turns?: int32;
}

@doc("Discriminated union of all data generation job option shapes.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
union DataGenerationJobOptions {
  QuestionAnswersDataGenerationJobOptions,
  MultipleChoiceQuestionsDataGenerationJobOptions,
  QuestionAnswersWithToolsDataGenerationJobOptions,
}

@doc("Model generation sampling / configuration options.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationModelOptions {
  @doc("Base model name used to generate synthetic data.")
  model: string;

  @doc("Sampling temperature used when generating content.")
  temperature?: float64;

  @doc("Maximum tokens to generate per sample.")
  max_tokens?: int32;
}

@doc("Status values for a data generation job.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
union DataGenerationJobStatus {
  string,

  @doc("Job has been queued and is waiting to start.")
  queued: "queued",

  @doc("Job is currently running.")
  running: "running",

  @doc("Job completed successfully.")
  succeeded: "succeeded",

  @doc("Job failed.")
  failed: "failed",
}

@doc("Data Generation Job create parameters.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationJobCreateParams {
  @doc("The kind of data generation job to run.")
  type: DataGenerationJobType;

  @doc("Options controlling generation behavior.")
  options: DataGenerationJobOptions;

  @doc("Seed data sources used as input.")
  seed_data_sources: Array<DataGenerationSeedDataSource>;

  @doc("Underlying model configuration.")
  model_options: DataGenerationModelOptions;
}

@doc("Data Generation Job resource.")
@added(Versions.v2025_05_15_preview)
@removed(Versions.v1)
model DataGenerationJob {
  @doc("The object type, always 'data_generation.job'.")
  object: string = "data_generation.job";

  @doc("The job identifier.")
  id: string;

  @doc("The current status of the job.")
  status: DataGenerationJobStatus;

  @doc("Identifiers of any result files produced after successful completion.")
  result_files?: Array<string>;

  @doc("The kind of data generation job executed.")
  type: DataGenerationJobType;

  @doc("Options used during generation.")
  options: DataGenerationJobOptions;

  @doc("Seed data sources used as input.")
  seed_data_sources: Array<DataGenerationSeedDataSource>;

  @doc("Underlying model configuration.")
  model_options: DataGenerationModelOptions;

  @doc("Error information set only when status is 'failed'.")
  error?: DataGenerationJobError;
}
