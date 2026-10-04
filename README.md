# Leopard Cat Camera Trap Research Dashboard

Dashboard penelitian berbasis Flutter Web untuk mendukung pengelolaan dan visualisasi data camera trap leopard cat.

## 1. Deskripsi Project

Project ini merupakan bagian dari pengembangan sistem Computer Vision untuk analisis citra camera trap.

Sistem menggunakan konsep event sebagai unit analisis. Satu event terdiri dari tiga foto yang dihasilkan dari satu trigger camera trap.

Dashboard digunakan untuk menampilkan hasil pengolahan dataset, klasifikasi event, kandidat individu leopard cat, serta distribusi occurrence berdasarkan waktu.

---

## 2. Tujuan Sistem

Sistem dikembangkan untuk membantu proses:

- pengelolaan data camera trap;
- pengelompokan foto menjadi event;
- klasifikasi event menjadi `leopard_cat` atau `null`;
- pengelompokan kandidat individu leopard cat;
- visualisasi occurrence berdasarkan timestamp;
- penyajian hasil analisis dalam dashboard berbasis web.

---

## 3. Dataset

Dataset penelitian berasal dari data camera trap yang tersimpan secara lokal.

Dataset awal terdiri dari dua kelas:

- `leopard_cat`
- `null`

Hasil pembentukan event menghasilkan:

| Komponen | Jumlah |
|---|---:|
| Total Events | 135 |
| Leopard Cat Events | 63 |
| Null Events | 72 |
| Total Photos | 405 |
| Photos per Event | 3 |

Satu event mempertahankan tiga foto yang berasal dari trigger camera trap yang sama.

---

## 4. Dataset Split

Dataset dibagi berdasarkan event sehingga tiga foto dalam satu event tetap berada pada subset yang sama.

Pembagian dataset:

| Subset | Events | Photos |
|---|---:|---:|
| Train | 94 | 282 |
| Validation | 20 | 60 |
| Test | 21 | 63 |
| Total | 135 | 405 |

Pembagian dilakukan menggunakan random seed 42.

---

## 5. Classification

Model classification digunakan untuk membedakan event menjadi:

```text
leopard_cat
null