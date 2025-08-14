# Generate parallelisation configuration

# 记得调整```gen_para_config.py``` 中的 ```host = ['nodename']```

## Example
```py
python gen_para_config.py \
    --model gpt \
    --size large \
    --precision fp16 \
    --pp 1 \
    --tp 2 \
    --dp 2
```
