![image](https://user-images.githubusercontent.com/35042430/164379975-a5e36f71-5f0b-4ef6-b305-d0935af9b633.png)


```{SQL}
SELECT * FROM table WHERE time_column < to_timestamp(TO_CHAR(NOW(),'HH:MM:SS'),'HH:MM:SS')::TIME;
```
