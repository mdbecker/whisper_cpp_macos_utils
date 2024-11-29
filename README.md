## README for `whisper_cpp_macos_utils`

### Purpose

The `whisper_cpp_macos_utils` repository provides shell scripts to simplify audio transcription workflows on macOS. These utilities integrate OpenAI's `whisper.cpp` with macOS tools like QuickTime Player and BlackHole-2ch to automate tasks such as retrieving QuickTime recordings, converting audio formats, and generating transcriptions.

This project is ideal for users who frequently record audio (e.g., meetings, lectures, or system audio) and need an efficient, streamlined way to process these recordings into text.

---

### Prerequisites

Before using the utilities, ensure the following are installed and configured:

1. **Required Tools:**
   - BlackHole-2ch for audio routing:
     ```bash
     brew install --cask blackhole-2ch
     ```
   - FFmpeg for audio format conversion:
     ```bash
     brew install ffmpeg
     ```
   - Xcode Command Line Tools:
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
     git clone https://github.com/ggerganov/whisper.cpp.git
     cd whisper.cpp
     ```

---

### Workflow Overview

The typical workflow involves recording audio, processing the files, and generating transcriptions. These steps can be automated using the provided scripts.

#### **Workflow Steps**
1. Record audio with QuickTime Player and BlackHole-2ch.
2. Run the following scripts:
   - `quicktime_fix.sh`: Retrieve and rename QuickTime autosave files.
   - `m4a_to_wav.sh`: Convert `.m4a` files to `.wav`.
   - `wav_to_txt_p.sh`: Transcribe `.wav` files to `.txt`.
3. Alternatively, use `chain_workflow.sh` to run all the above steps in sequence.

---

### Repository Contents

#### **Script Summaries**

1. **`build_and_test_models.sh`**
   - Builds the `whisper.cpp` binary with Metal support for macOS.
   - Downloads and tests Whisper models for transcription.

   **Usage:**
   ```bash
   bash ../whisper_cpp_macos_utils/build_and_test_models.sh -m large-v3-turbo-q5_0
   ```

   - **Options:**
     - `-m`: Comma-separated list of Whisper models to download and test.
     - `-t`: Number of threads for building (default: auto-detect).

   **Note:** Requires macOS Ventura (version 13) or later for [Metal](https://developer.apple.com/metal/) support.

2. **`quicktime_fix.sh`**
   - Retrieves and renames QuickTime autosave files with timestamps, moves them to a specified directory, and deletes the original autosave directories.

   **Usage:**
   ```bash
   bash quicktime_fix.sh
   ```

   - **Default Directories:**
     - **Source:** `~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave Information/`
     - **Destination:** `~/Documents/new_recordings/`

3. **`m4a_to_wav.sh`**
   - Converts `.m4a` files in the `new_recordings` directory to `.wav` format.
   - Moves processed `.m4a` files to `old_recordings`.

   **Usage:**
   ```bash
   bash m4a_to_wav.sh
   ```

   - **Default Directories:**
     - **Source:** `~/Documents/new_recordings/`
     - **Destination for `.wav`:** `~/git/whisper.cpp/`
     - **Moved `.m4a` Files:** `~/Documents/old_recordings/`

4. **`wav_to_txt_p.sh`**
   - Transcribes `.wav` files into `.txt` using a specified Whisper model.
   - Processes files in parallel for efficiency.

   **Usage:**
   ```bash
   bash wav_to_txt_p.sh -m large-v3-turbo-q5_0
   ```

   - **Options:**
     - `-m`: Specify the Whisper model (default: `large-v3-turbo-q5_0`).
     - `-p`: Number of parallel jobs (default: `7`).

5. **`chain_workflow.sh`**
   - Automates the full workflow:
     1. Retrieve QuickTime autosave recordings.
     2. Convert `.m4a` files to `.wav`.
     3. Transcribe `.wav` files into `.txt`.

   **Usage:**
   ```bash
   bash chain_workflow.sh
   ```

---

### Example Workflow

To automate the transcription workflow, follow these steps:

1. **Record Audio:**
   - Use QuickTime Player and BlackHole-2ch to record audio.

2. **Process Files:**
   ```bash
   bash quicktime_fix.sh    # Retrieve QuickTime recordings
   bash m4a_to_wav.sh       # Convert .m4a to .wav
   bash wav_to_txt_p.sh     # Transcribe .wav to .txt
   ```

3. **Full Automation:**
   ```bash
   bash chain_workflow.sh
   ```

4. **Prepare Whisper Models (Optional):**
   - To download and test specific Whisper models:
     ```bash
     bash build_and_test_models.sh -m large-v2,large-v3-turbo
     ```

---

### Notes

- Use an appropriate Whisper model (`large-v2`, `large-v3-turbo`, etc.) based on your hardware and transcription needs.
- For additional configuration or troubleshooting, refer to the `whisper.cpp` [documentation](https://github.com/ggerganov/whisper.cpp).
