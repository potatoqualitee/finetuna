# Fine-tuning

Manage fine-tuning jobs to tailor a model to your specific training data.

### Create Fine-tuning Job
**POST**
`https://api.openai.com/v1/fine_tuning/jobs`

Creates a fine-tuning job which begins the process of creating a new model from a given dataset. The response includes details of the enqueued job, including job status and the name of the fine-tuned models once complete.

[Learn more about fine-tuning](https://platform.openai.com/docs/guides/fine-tuning)

#### Request Body
- **model**: `string` (Required)
  The name of the model to fine-tune. You can select one of the supported models.
- **training_file**: `string` (Required)
  The ID of an uploaded file that contains training data. Your dataset must be formatted as a JSONL file. Additionally, you must upload your file with the purpose `fine-tune`. The contents of the file should differ depending on if the model uses the chat or completions format. See the fine-tuning guide for more details.
- **hyperparameters**: `object` (Optional)
  The hyperparameters used for the fine-tuning job.
- **suffix**: `string` or `null` (Optional)
  Defaults to `null`. A string of up to 18 characters that will be added to your fine-tuned model name. For example, a suffix of "custom-model-name" would produce a model name like `ft:gpt-3.5-turbo:openai:custom-model-name:7p4lURel`.
- **validation_file**: `string` or `null` (Optional)
  The ID of an uploaded file that contains validation data. If you provide this file, the data is used to generate validation metrics periodically during fine-tuning. These metrics can be viewed in the fine-tuning results file. The same data should not be present in both train and validation files. Your dataset must be formatted as a JSONL file.
- **integrations**: `array` or `null` (Optional)
  A list of integrations to enable for your fine-tuning job.
- **seed**: `integer` or `null` (Optional)
  The seed controls the reproducibility of the job. Passing in the same seed and job parameters should produce the same results, but may differ in rare cases. If a seed is not specified, one will be generated for you.

#### Returns
A `fine-tuning.job` object.

#### Example Request
```bash
curl https://api.openai.com/v1/fine_tuning/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "training_file": "file-abc123",
    "validation_file": "file-abc123",
    "model": "gpt-3.5-turbo",
    "integrations": [
      {
        "type": "wandb",
        "wandb": {
          "project": "my-wandb-project",
          "name": "ft-run-display-name",
          "tags": [
            "first-experiment", "v2"
          ]
        }
      }
    ]
  }'
```

#### Response
```json
{
  "object": "fine_tuning.job",
  "id": "ftjob-abc123",
  "model": "gpt-3.5-turbo-0125",
  "created_at": 1614807352,
  "fine_tuned_model": null,
  "organization_id": "org-123",
  "result_files": [],
  "status": "queued",
  "validation_file": "file-abc123",
  "training_file": "file-abc123",
  "integrations": [
    {
      "type": "wandb",
      "wandb": {
        "project": "my-wandb-project",
        "entity": null,
        "run_id": "ftjob-abc123"
      }
    }
  ]
}
```

### List Fine-tuning Jobs
**GET**
`https://api.openai.com/v1/fine_tuning/jobs`

List your organization's fine-tuning jobs.

#### Query Parameters
- **after**: `string` (Optional)
  Identifier for the last job from the previous pagination request.
- **limit**: `integer` (Optional)
  Defaults to `20`. Number of fine-tuning jobs to retrieve.

#### Returns
A list of paginated fine-tuning job objects.

#### Example Request
```javascript
import OpenAI from "openai";

const openai = new OpenAI();

async function main() {
  const list = await openai.fineTuning.jobs.list();

  for await (const fineTune of list) {
    console.log(fineTune);
  }
}

main();
```

#### Response
```json
{
  "object": "list",
  "data": [
    {
      "object": "fine_tuning.job.event",
      "id": "ft-event-TjX0lMfOniCZX64t9PUQT5hn",
      "created_at": 1689813489,
      "level": "warn",
      "message": "Fine tuning process stopping due to job cancellation",
      "data": null,
      "type": "message"
    },
    { ... },
    { ... }
  ],
  "has_more": true
}
```

### List Fine-tuning Events
**GET**
`https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/events`

Get status updates for a fine-tuning job.

#### Path Parameters
- **fine_tuning_job_id**: `string` (Required)
  The ID of the fine-tuning job to get events for.

#### Query Parameters
- **after**: `string` (Optional)
  Identifier for the last event from the previous pagination request.
- **limit**: `integer` (Optional)
  Defaults to `20`. Number of events to retrieve.

#### Returns
A list of fine-tuning event objects.

#### Example Request
```javascript
import OpenAI from "openai";

const openai = new OpenAI();

async function main() {
  const list = await openai.fineTuning.list_events(id="ftjob-abc123", limit=2);

  for await (const fineTune of list) {
    console.log(fineTune);
  }
}

main();
```

#### Response
```json
{
  "object": "list",
  "data": [
    {
      "object": "fine_tuning.job.event",
      "id": "ft-event-ddTJfwuMVpfLXseO0Am0Gqjm",
      "created_at": 1692407401,
      "level": "info",
      "message": "Fine tuning job successfully completed",
      "data": null,
      "type": "message"
    },
    {
      "object": "fine_tuning.job.event",
      "id": "ft-event-tyiGuB72evQncpH87xe505Sv",
      "created_at": 1692407400,
      "level": "info",
      "message": "New fine-tuned model created: ft:gpt-3.5-turbo:openai::7p4lURel",
      "data": null,
      "type": "message"
    }
  ],
  "has_more": true
}
```

### List Fine-tuning Checkpoints
**GET**
`https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/checkpoints`

List checkpoints for a fine-tuning job.

#### Path Parameters
- **fine_tuning_job_id**: `string` (Required)
  The ID of the fine-tuning job to get checkpoints for.

#### Query Parameters
- **after**: `string` (Optional)
  Identifier for the last checkpoint ID from the previous pagination request.
- **limit**: `integer` (Optional)
  Defaults to `10`. Number of checkpoints to retrieve.

#### Returns
A list of fine-tuning checkpoint objects for a fine-tuning job.

#### Example Request
```bash
curl https://api.openai.com/v1/fine_tuning/jobs/ftjob-abc123/checkpoints \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

#### Response
```json
{
  "object": "list",
  "data": [
    {
      "object": "fine_tuning.job.checkpoint",
      "id": "ftckpt_zc4Q7MP6XxulcVzj4MZdwsAB",
      "created_at": 1519129973,
      "fine_tuned_model_checkpoint": "ft:gpt-3.5-turbo-0125:my-org:custom-suffix:96olL566:ckpt-step-2000",
      "metrics": {
        "full_valid_loss": 0.134,
        "full_valid_mean_token_accuracy": 0.874
      },
      "fine_tuning_job_id": "ftjob-abc123",
      "step_number": 2000
    },
    {
      "object": "fine_tuning.job.checkpoint",
      "id": "ftckpt_enQCFmOTGj3syEpYVhBRLTSy",
      "created_at": 1519129833,
      "fine_tuned_model_checkpoint": "ft:gpt-3.5-turbo-0125:my-org:custom-suffix:7q8mpxmy:ckpt-step-1000

",
      "metrics": {
        "full_valid_loss": 0.167,
        "full_valid_mean_token_accuracy": 0.781
      },
      "fine_tuning_job_id": "ftjob-abc123",
      "step_number": 1000
    }
  ],
  "first_id": "ftckpt_zc4Q7MP6XxulcVzj4MZdwsAB",
  "last_id": "ftckpt_enQCFmOTGj3syEpYVhBRLTSy",
  "has_more": true
}
```

### Retrieve Fine-tuning Job
**GET**
`https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}`

Get info about a fine-tuning job.

[Learn more about fine-tuning](#)

#### Path Parameters
- **fine_tuning_job_id**: `string` (Required)
  The ID of the fine-tuning job.

#### Returns
The fine-tuning object with the given ID.

#### Example Request
```javascript
import OpenAI from "openai";

const openai = new OpenAI();

async function main() {
  const fineTune = await openai.fineTuning.jobs.retrieve("ftjob-abc123");

  console.log(fineTune);
}

main();
```

#### Response
```json
{
  "object": "fine_tuning.job",
  "id": "ftjob-abc123",
  "model": "davinci-002",
  "created_at": 1692661014,
  "finished_at": 1692661190,
  "fine_tuned_model": "ft:davinci-002:my-org:custom_suffix:7q8mpxmy",
  "organization_id": "org-123",
  "result_files": [
      "file-abc123"
  ],
  "status": "succeeded",
  "validation_file": null,
  "training_file": "file-abc123",
  "hyperparameters": {
      "n_epochs": 4,
      "batch_size": 1,
      "learning_rate_multiplier": 1.0
  },
  "trained_tokens": 5768,
  "integrations": [],
  "seed": 0,
  "estimated_finish": 0
}
```

### Cancel Fine-tuning
**POST**
`https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel`

Immediately cancel a fine-tune job.

#### Path Parameters
- **fine_tuning_job_id**: `string` (Required)
  The ID of the fine-tuning job to cancel.

#### Returns
The cancelled fine-tuning object.

#### Example Request
```javascript
import OpenAI from "openai";

const openai = new OpenAI();

async function main() {
  const fineTune = await openai.fineTuning.jobs.cancel("ftjob-abc123");

  console.log(fineTune);
}

main();
```

#### Response
```json
{
  "object": "fine_tuning.job",
  "id": "ftjob-abc123",
  "model": "gpt-3.5-turbo-0125",
  "created_at": 1689376978,
  "fine_tuned_model": null,
  "organization_id": "org-123",
  "result_files": [],
  "hyperparameters": {
    "n_epochs": "auto"
  },
  "status": "cancelled",
  "validation_file": "file-abc123",
  "training_file": "file-abc123"
}
```

### Training Format for Chat Models
The per-line training example of a fine-tuning input file for chat models.

- **messages**: `array`
- **tools**: `array`
  A list of tools the model may generate JSON inputs for.
- **parallel_tool_calls**: `boolean`
  Whether to enable parallel function calling during tool use.
- **functions**: `array` (Deprecated)
  A list of functions the model may generate JSON inputs for.

#### Example
```json
{
  "messages": [
    { "role": "user", "content": "What is the weather in San Francisco?" },
    {
      "role": "assistant",
      "tool_calls": [
        {
          "id": "call_id",
          "type": "function",
          "function": {
            "name": "get_current_weather",
            "arguments": "{\"location\": \"San Francisco, USA\", \"format\": \"celsius\"}"
          }
        }
      ]
    }
  ],
  "parallel_tool_calls": false,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_current_weather",
        "description": "Get the current weather",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {
                "type": "string",
                "description": "The city and country, eg. San Francisco, USA"
            },
            "format": { "type": "string", "enum": ["celsius", "fahrenheit"] }
          },
          "required": ["location", "format"]
        }
      }
    }
  ]
}
```

### Training Format for Completions Models
The per-line training example of a fine-tuning input file for completions models.

- **prompt**: `string`
  The input prompt for this training example.
- **completion**: `string`
  The desired completion for this training example.

#### Example
```json
{
  "prompt": "What is the answer to 2+2",
  "completion": "4"
}
```

## The Fine-tuning Job Object
The `fine_tuning.job` object represents a fine-tuning job that has been created through the API.

- **id**: `string`
  The object identifier, which can be referenced in the API endpoints.
- **created_at**: `integer`
  The Unix timestamp (in seconds) for when the fine-tuning job was created.
- **error**: `object` or `null`
  For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
- **fine_tuned_model**: `string` or `null`
  The name of the fine-tuned model that is being created. The value will be null if the fine-tuning job is still running.
- **finished_at**: `integer` or `null`
  The Unix timestamp (in seconds) for when the fine-tuning job was finished. The value will be null if the fine-tuning job is still running.
- **hyperparameters**: `object`
  The hyperparameters used for the fine-tuning job. See the fine-tuning guide for more details.
- **model**: `string`
  The base model that is being fine-tuned.
- **object**: `string`
  The object type, which is always `fine_tuning.job`.
- **organization_id**: `string`
  The organization that owns the fine-tuning job.
- **result_files**: `array`
  The compiled results file ID(s) for the fine-tuning job. You can retrieve the results with the Files API.
- **status**: `string`
  The current status of the fine-tuning job, which can be either validating_files, queued, running, succeeded, failed, or cancelled.
- **trained_tokens**: `integer` or `null`
  The total number of billable tokens processed by this fine-tuning job. The value will be null if the fine-tuning job is still running.
- **training_file**: `string`
  The file ID used for training. You can retrieve the training data with the Files API.
- **validation_file**: `string` or `null`
  The file ID used for validation. You can retrieve the validation results with the Files API.
- **integrations**: `array` or `null`
  A list of integrations to enable for this fine-tuning job.
- **seed**: `integer`
  The seed used for the fine-tuning job.
- **estimated_finish**: `integer` or `null`
  The Unix timestamp (in seconds) for when the fine-tuning job is estimated to finish. The value will be null if the fine-tuning job is not running.

#### Example
```json
{
  "object": "fine_tuning.job",
  "id": "ftjob-abc123",
  "model": "davinci-002",
  "created_at": 1692661014,
  "finished_at": 1692661190,
  "fine_tuned_model": "ft:davinci-002:my-org:custom_suffix:7q8mpxmy",
  "organization_id": "org-123",
  "result_files": [
      "file-abc123"
  ],
  "status": "succeeded",
  "validation_file": null,
  "training_file": "file-abc123",
  "hyperparameters": {
      "n_epochs": 4,
      "batch_size": 1,
      "learning_rate_multiplier": 1.0
  },
  "trained_tokens": 5768,
  "integrations": [],
  "seed": 0,
  "estimated_finish": 0
}
```

## The Fine-tuning Job Event Object
The `fine_tuning.job.event` object represents an event during a fine-tuning job.

- **id**: `string`
- **created_at**: `integer`
- **level**: `string`
- **

message**: `string`
- **object**: `string`

#### Example
```json
{
  "object": "fine_tuning.job.event",
  "id": "ftevent-abc123",
  "created_at": 1677610602,
  "level": "info",
  "message": "Created fine-tuning job"
}
```

## The Fine-tuning Job Checkpoint Object
The `fine_tuning.job.checkpoint` object represents a model checkpoint for a fine-tuning job that is ready to use.

- **id**: `string`
  The checkpoint identifier, which can be referenced in the API endpoints.
- **created_at**: `integer`
  The Unix timestamp (in seconds) for when the checkpoint was created.
- **fine_tuned_model_checkpoint**: `string`
  The name of the fine-tuned checkpoint model that is created.
- **step_number**: `integer`
  The step number that the checkpoint was created at.
- **metrics**: `object`
  Metrics at the step number during the fine-tuning job.
- **fine_tuning_job_id**: `string`
  The name of the fine-tuning job that this checkpoint was created from.
- **object**: `string`
  The object type, which is always `fine_tuning.job.checkpoint`.

#### Example
```json
{
  "object": "fine_tuning.job.checkpoint",
  "id": "ftckpt_zc4Q7MP6XxulcVzj4MZdwsAB",
  "created_at": 1519129973,
  "fine_tuned_model_checkpoint": "ft:gpt-3.5-turbo-0125:my-org:custom-suffix:96olL566:ckpt-step-2000",
  "metrics": {
    "full_valid_loss": 0.134,
    "full_valid_mean_token_accuracy": 0.874
  },
  "fine_tuning_job_id": "ftjob-abc123",
  "step_number": 2000
}
```