--------------------------------- README ---------------------------------------
1. buat database di postgresql
2. buat table beserta kolomnya.
3. import file dataset csv nya.
   untuk import file bisa ikuti promt berikut
       \copy public.layoffs_2
       FROM 'C:\Users\yuliatun\Documents\DATA ANALIS\SQL\layoffs.csv'
       WITH (
         FORMAT csv,
         DELIMITER ',',
         HEADER,
         QUOTE '"',
         NULL 'NULL'
       );
5. lalu bisa copy file layoff.sql
