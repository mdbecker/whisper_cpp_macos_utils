## README for `whisper_cpp_macos_utils`

### Purpose

The `whisper_cpp_macos_utils` repository provides shell scripts to simplify audio transcription workflows on macOS. These utilities integrate OpenAI's Whisper (via [`whisper.cpp`](https://github.com/ggerganov/whisper.cpp)) with macOS tools like QuickTime Player and BlackHole-2ch to automate tasks such as retrieving QuickTime recordings, converting audio formats, and generating transcriptions.

This project is ideal for users who frequently record audio (e.g., meetings, lectures, or system audio) and need an efficient, streamlined way to process these recordings into text.

---

### Table of Contents

- [Prerequisites](#prerequisites)
- [Workflow Overview](#workflow-overview)
- [Repository Contents](#repository-contents)
  - [`build_and_test_models.sh`](#build_and_test_modelssh)
  - [`quicktime_fix.sh`](#quicktime_fixsh)
  - [`m4a_to_wav.sh`](#m4a_to_wavsh)
  - [`wav_to_txt_p.sh`](#wav_to_txt_psh)
  - [`chain_workflow.sh`](#chain_workflowsh)
- [Notes](#notes)
- [Example Workflow](#example-workflow)

---

### Prerequisites

*Note: This guide assumes that **[Homebrew](https://brew.sh/)** is already installed and that you are familiar with using the **[terminal](https://iterm2.com/)**.*

Before using the utilities, ensure the following are installed and configured:

1. **Required Tools:**
   - **BlackHole-2ch** for audio routing:
     ```bash
     brew install --cask blackhole-2ch
     ```
   - **FFmpeg** for audio format conversion:
     ```bash
     brew install ffmpeg
     ```
   - **Xcode Command Line Tools**:
     ```bash
     xcode-select --install
     ```

2. **Configure Audio Routing:**
   - Use BlackHole-2ch to route system audio to QuickTime Player.
   - Set macOS audio output to BlackHole and input to a microphone or BlackHole itself.

   For setup instructions, see:
   - [Guide](https://andreyazimov.medium.com/how-to-record-desktop-audio-on-your-mac-in-2023-8aab7c29bffd)
   - [Video](https://youtu.be/KjL_sJS9Rko?si=MfjBMnO-BvOr487F&t=227)
   - [BlackHole Wiki](https://github.com/ExistentialAudio/BlackHole/wiki)

3. **Prepare Whisper.cpp:**
   - Clone the `whisper.cpp` repository:
     ```bash
     mkdir -p ~/git
     cd ~/git
     git clone https://github.com/ggerganov/whisper.cpp.git
     cd whisper.cpp
     ```

---

### Workflow Overview

The typical workflow involves recording audio, processing the files, and generating transcriptions. These steps can be automated using the provided scripts:

1. **Record Audio:**
   - Use QuickTime Player and BlackHole-2ch to record audio.

2. **Process and Transcribe Recordings:**
   - **Option 1:** Use the individual scripts:
     - `quicktime_fix.sh`: Retrieve and rename QuickTime autosave files.
     - `m4a_to_wav.sh`: Convert `.m4a` files to `.wav`.
     - `wav_to_txt_p.sh`: Transcribe `.wav` files to `.txt`.
   - **Option 2:** Use `chain_workflow.sh` to automate the full workflow with customizable options.

---

### Repository Contents

#### Script Summaries

##### `build_and_test_models.sh`

- Builds the `whisper.cpp` binary with Metal support for macOS.
- Downloads and tests Whisper models for transcription.

**Options:**
- `-m`: Comma-separated list of Whisper models to download and test.
- `-t`: Number of threads for building (default: auto-detect).

**Example:**
```bash
cd ~/git/whisper.cpp
bash ../whisper_cpp_macos_utils/build_and_test_models.sh -m large-v2,large-v3-turbo,large-v3-turbo-q5_0 -t 8
```

**Note:** Requires macOS Ventura (version 13) or later for [Metal](https://developer.apple.com/metal/) support. For older macOS versions, manually build Whisper with CPU support.

##### `quicktime_fix.sh`

- Retrieves and renames QuickTime autosave files with timestamps, moves them to a specified directory, and deletes the original autosave directories.

**Options:**
- `-s <source_dir>`: Source directory to search for autosave files (default: `~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave Information/`).
- `-d <destination_dir>`: Directory to save retrieved files (default: `~/Documents/new_recordings/`).

**Example with Defaults:**
```bash
bash quicktime_fix.sh
```

**Example with Custom Directories:**
```bash
bash quicktime_fix.sh -s ~/custom_autosave_dir -d ~/custom_recordings_dir
```

##### `m4a_to_wav.sh`

- Converts `.m4a` files to `.wav` format and moves processed files to a separate directory.
- Accepts customizable directories via arguments.

**Options:**
- `-i <input_dir>`: Directory containing `.m4a` files to process (default: `~/Documents/new_recordings/`).
- `-o <output_dir>`: Directory to save `.wav` files (default: `~/git/whisper.cpp/`).
- `-p <processed_dir>`: Directory to move processed `.m4a` files (default: `~/Documents/old_recordings/`).

**Example with Defaults:**
```bash
bash m4a_to_wav.sh
```

**Example with Custom Directories:**
```bash
bash m4a_to_wav.sh -i ~/custom_input -o ~/custom_output -p ~/processed_files
```

##### `wav_to_txt_p.sh`

- Transcribes `.wav` files into `.txt` using a specified Whisper model.
- Supports parallel processing and configurable directories.

**Options:**
- `-m <model>`: Specify the Whisper model to use (default: `large-v3-turbo-q5_0`).
- `-p <parallel_jobs>`: Number of parallel jobs (default: `7`).
- `-i <input_dir>`: Directory containing `.wav` files to process (default: `~/git/whisper.cpp/`).
- `-o <output_dir>`: Directory to save `.txt` transcriptions (default: `~/git/whisper.cpp/`).

**Example with Defaults:**
```bash
bash wav_to_txt_p.sh
```

**Example with Custom Options:**
```bash
bash wav_to_txt_p.sh -m large-v2 -p 4 -i ~/custom_wav_dir -o ~/custom_txt_dir
```

##### `chain_workflow.sh`

- Automates the full workflow:
  - Retrieves QuickTime autosave recordings.
  - Converts `.m4a` files to `.wav`.
  - Transcribes `.wav` files into `.txt`.
- Supports overriding options for the individual scripts to maintain consistency.

**Options:**
- `--qt-src <path>`: Source directory for QuickTime autosave files (default: `~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave Information/`).
- `--qt-dest <path>`: Destination directory for QuickTime recordings (default: `~/Documents/new_recordings/`).
- `--m4a-output <path>`: Directory to save `.wav` files and transcriptions (default: `~/git/whisper.cpp/`).
- `--processed-dir <path>`: Directory to move processed `.m4a` files (default: `~/Documents/old_recordings/`).
- `--whisper-model <model>`: Whisper model to use (default: `large-v3-turbo-q5_0`).
- `--parallel-jobs <num>`: Number of parallel jobs for transcription (default: `7`).

**Example with Defaults:**
```bash
bash chain_workflow.sh
```

**Example with Custom Options:**
```bash
bash chain_workflow.sh --qt-src ~/custom_autosave_dir --qt-dest ~/custom_new_recordings --m4a-output ~/custom_wav_dir --processed-dir ~/custom_old_recordings --whisper-model large-v2 --parallel-jobs 4
```

---

### Notes

- **Whisper Models:** Use an appropriate Whisper model (`large-v2`, `large-v3-turbo`, `large-v3-turbo-q5_0`, etc.) based on your hardware and transcription needs. Models with quantization (e.g., `-q5_0`) may offer faster performance with reduced memory usage.
- **Additional Resources:** For additional configuration or troubleshooting, refer to the `whisper.cpp` [documentation](https://github.com/ggerganov/whisper.cpp).

---

### Example Workflow

Here's an example of the entire transcription workflow using default options:

```bash
# Step 1: Retrieve QuickTime recordings
bash quicktime_fix.sh

# Step 2: Convert recordings to WAV format
bash m4a_to_wav.sh

# Step 3: Transcribe WAV files
bash wav_to_txt_p.sh
```

For full automation with default options:

```bash
bash chain_workflow.sh
```

For full automation with custom options:

```bash
bash chain_workflow.sh \
  --qt-src ~/custom_autosave_dir \
  --qt-dest ~/custom_new_recordings \
  --m4a-output ~/custom_wav_dir \
  --processed-dir ~/custom_old_recordings \
  --whisper-model large-v2 \
  --parallel-jobs 4
```
