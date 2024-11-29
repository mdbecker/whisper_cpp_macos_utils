## README for `whisper_cpp_macos_utils`

### Purpose

The `whisper_cpp_macos_utils` repository provides shell scripts to simplify audio transcription workflows on macOS. These utilities integrate OpenAI's `whisper.cpp` with macOS tools like QuickTime Player and BlackHole-2ch to automate tasks such as retrieving QuickTime recordings, converting audio formats, and generating transcriptions.

This project is ideal for users who frequently record audio (e.g., meetings, lectures, or system audio) and need an efficient, streamlined way to process these recordings into text.

---

### Workflow Overview

1. **Record Audio with QuickTime and BlackHole-2ch:**
   - Install BlackHole-2ch:
     ```bash
     brew install --cask blackhole-2ch
     ```
   - Configure macOS audio settings to route output to BlackHole and input from a microphone or BlackHole itself.
   - Open QuickTime Player, start a new audio recording, and set input to BlackHole.
   - **For detailed instructions on configuring BlackHole-2ch with QuickTime Player, see [this guide](ADD_LINK_HERE).**

2. **Run the Scripts:**
   - `quicktime_fix.sh`: Retrieve and rename QuickTime autosave files.
   - `m4a_to_wav.sh`: Convert `.m4a` files to `.wav`.
   - `wav_to_txt_p.sh`: Transcribe `.wav` files to `.txt` using Whisper models.
   - Optionally, use `build_and_test_models.sh` to prepare Whisper models for transcription.

3. **Output:**
   - Transcriptions are saved as `.txt` files corresponding to the audio filenames.

---

### Repository Contents

#### **`build_and_test_models.sh`**
Builds the `whisper.cpp` binary with Metal support on macOS and downloads Whisper models for transcription.

**Note:** Requires macOS Ventura (version 13) or later for [Metal](https://developer.apple.com/metal/) support.

#### Prerequisites
Before running `build_and_test_models.sh`, ensure the following prerequisites are met:

1. **Install Required Tools:**
   - BlackHole-2ch for audio recording:
     ```bash
     brew install --cask blackhole-2ch
     ```
   - FFmpeg for audio conversion:
     ```bash
     brew install ffmpeg
     ```
   - Xcode Command Line Tools:
     ```bash
     xcode-select --install
     ```

2. **Prepare Whisper.cpp:**
   - Clone the `whisper.cpp` repository:
     ```bash
     git clone https://github.com/ggerganov/whisper.cpp.git
     cd whisper.cpp
     ```

#### Usage
Run the script from within the `whisper.cpp` directory:
```bash
bash ../whisper_cpp_macos_utils/build_and_test_models.sh -m large-v3-turbo-q5_0
```

- **Options:**
  - `-m`: Comma-separated list of Whisper models to download and test.
  - `-t`: Number of threads for building (default: auto-detect).

---

#### **`quicktime_fix.sh`**
Retrieves and renames QuickTime autosave files with timestamps, moves them to a specified directory, and deletes the original autosave directories.

**Usage:**
```bash
bash quicktime_fix.sh
```

- **Default Directories:**
  - **Source:** `~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave Information/`
  - **Destination:** `~/Documents/new_recordings/`

---

#### **`m4a_to_wav.sh`**
Converts `.m4a` files in the `new_recordings` directory to `.wav` format, moves processed `.m4a` files to `old_recordings`, and retains timestamps.

**Usage:**
```bash
bash m4a_to_wav.sh
```

- **Default Directories:**
  - **Source:** `~/Documents/new_recordings/`
  - **Destination for `.wav`:** `~/git/whisper.cpp/`
  - **Moved `.m4a` Files:** `~/Documents/old_recordings/`

---

#### **`wav_to_txt_p.sh`**
Transcribes `.wav` files into `.txt` using a specified Whisper model. Processes files in parallel for efficiency.

**Usage:**
```bash
bash wav_to_txt_p.sh -m large-v3-turbo-q5_0
```

- **Options:**
  - `-m`: Specify the Whisper model (default: `large-v3-turbo-q5_0`).
  - `-p`: Number of parallel jobs (default: `7`).

---

#### **`chain_workflow.sh`**
Automates the full workflow:
1. Retrieve QuickTime autosave recordings.
2. Convert `.m4a` files to `.wav`.
3. Transcribe `.wav` files into `.txt`.

**Usage:**
```bash
bash chain_workflow.sh
```

---

### Example Workflow

1. Record system audio using QuickTime and BlackHole-2ch.
2. Retrieve autosaved recordings:
   ```bash
   bash quicktime_fix.sh
   ```
3. Convert `.m4a` files to `.wav`:
   ```bash
   bash m4a_to_wav.sh
   ```
4. Transcribe `.wav` files into text:
   ```bash
   bash wav_to_txt_p.sh
   ```

For full automation:
```bash
bash chain_workflow.sh
```

---

### Notes

- Choose an appropriate Whisper model (`large-v2`, `large-v3-turbo`, etc.) based on your hardware and transcription needs.
