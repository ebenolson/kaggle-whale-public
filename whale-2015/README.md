### Description

Right Whale Recognition

- [Competition page at Kaggle](https://kaggle.com/c/noaa-right-whale-recognition)
- [Video recording of presentation](https://youtu.be/WfuDrJA6JBE)

### Usage

1. Download and install neon 1.1.4

    ```
    git clone https://github.com/NervanaSystems/neon.git
    cd neon
    git checkout e09fc11
    make
    source .venv/bin/activate
    ```

2. Install prerequisites

    ```
    pip install scipy scikit-image
    ```

3. Download the following files from [Kaggle](https://kaggle.com/c/noaa-right-whale-recognition/data):

    ```
    imgs.zip
    train.csv
    w_7489.jpg
    sample_submission.csv
    ```
    Save these to ../data.

4. Train localizer and generate predictions

    ```
    ./run_localizer.sh ../data
    ```