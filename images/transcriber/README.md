# Transcriber

Docker image for [transciber]. OpenAI Whisper as a service.

Defaults to use Whisper's medium english model to transcribe Audio and Video files.

Built from [Islandora-DevOps/isle-buildkit transciber](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/transciber)

## Dependencies

Requires [ggerganov/whisper.cpp](https://github.com/ggerganov/whisper.cpp) and `islandora/scyllaridae` docker image to build.

## Settings

| Environment Variable              | Default                                    | Description                                                                   |
| :-------------------------------- | :----------------------------------------- | :---------------------------------------------------------------------------- |
| `WHISPER_PROCESSORS`              | `1`                                        | How many processors the transcription service will use to transcribe the A/V. |
| `WHISPER_THREADS`                 | `2`                                        | How many threads the transcription service will use to transcribe the A/V.    |

## Attribution

- [OpenAI/whisper](https://github.com/openai/whisper)
- [ggerganov/whisper.cpp](https://github.com/ggerganov/whisper.cpp) to interact with the OpenAI Whisper model
