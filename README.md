# Đồ án Thực Hành: Hệ Thống Thông Tin Phục Vụ Cho Trí Tuệ Kinh Doanh (BI)
## Quản Lý Chuyến Bay

**Môn học:** Hệ thống thông tin phục vụ cho trí tuệ kinh doanh (CSC12107)  
**Lớp:** 22HTTT - **Nhóm:** 7  

---

### Giới thiệu dự án
Dự án tập trung xây dựng hệ thống Kho dữ liệu (Data Warehouse) cho lĩnh vực hàng không nhằm quản lý và phân tích dữ liệu chuyến bay, hãng hàng không, và sân bay. Thông qua đó, thực hiện các quy trình từ thiết kế mô hình, ETL, OLAP, trực quan hóa dữ liệu (Dashboard) cho đến Khai phá dữ liệu (Data Mining) để hỗ trợ ra quyết định.

---

### Video Demo
[Xem toàn bộ video Demo tại đây](https://drive.google.com/drive/folders/1uwhHqE-AaIsphgErjR2fi_sLmEaJFIRn?usp=drive_link)
Các video bao gồm:
- Trích xuất dữ liệu, làm sạch và nạp (ETL)
- Báo cáo và truy vấn đa chiều (OLAP_Report)
- Trực quan hóa dữ liệu (Dashboard_PowerBI)
- Khai phá tri thức (Mining_demo)

---

### Các thành phần chính của đồ án

#### 1. Thiết kế và cài đặt CSDL (NDS, DDS)
- **NDS (Normalized Data Store):** Thiết kế đạt chuẩn 1NF, 2NF và phân tích các vi phạm 3NF (dữ liệu dẫn xuất) đối với nhóm thời gian và thời gian trễ phù hợp với thực tế dữ liệu.
- **DDS (Dimensional Data Store):** Xây dựng theo mô hình Star Schema với bảng Fact trung tâm (`Fact_Flights`) và các bảng chiều (Dim_Date, Dim_Time, Dim_Airlines, Dim_Airports, Dim_Aircrafts, Dim_CancellationReasons). Áp dụng xử lý SCD Type 2 để theo dõi lịch sử thay đổi thông tin.

#### 2. Quy trình ETL (Extract - Transform - Load)
- Xây dựng luồng ETL chi tiết từ Source -> STG -> NDS -> DDS.
- Hệ thống Metadata & Logging: Quản lý chi tiết việc nạp dữ liệu tăng dần (Incremental Load với LSET/CET), kiểm soát chất lượng dữ liệu (Data Quality Rules/Issues), ghi nhận kết quả và lỗi tự động qua `ETL_RunLog` và `ETL_ErrorLog`.
- **Tự động hóa (Scheduling):** Ứng dụng Apache Airflow (trên Docker) kết hợp cấu hình SQL Server Agent để lập lịch tự động chạy các luồng dữ liệu theo thứ tự.

#### 3. Phân tích OLAP và Report
- Sử dụng SSAS (SQL Server Analysis Services) để tạo Cube đa chiều.
- Viết các truy vấn MDX và SQL (báo cáo qua Excel) tương ứng để giải quyết các bài toán nghiệp vụ như:
  - Tổng số chuyến bay theo tháng, quý, năm.
  - Top 5 sân bay bận rộn nhất.
  - Tỉ lệ chuyến bay đúng giờ (OTP).
  - Nguyên nhân và thời gian delay trung bình.

#### 4. Trực quan hóa dữ liệu (Dashboard)
- Xây dựng báo cáo động trên **Power BI** với các tính năng phân tích chi tiết.
- **Dashboard Quản lý (Tổng quan hiệu suất):** Giám sát hiệu suất toàn ngành (tổng chuyến bay, tỉ lệ hủy, delay nghiêm trọng), top hiệu suất theo hãng và sân bay.
- **Dashboard Phân tích nguyên nhân:** Đào sâu vào nguyên nhân trễ chuyến và hủy chuyến theo khung giờ, tính mùa vụ và đánh giá mức độ đóng góp của từng sân bay vào việc chậm trễ.
- **AI Tích hợp:** Ứng dụng tính năng *Smart Narrative* của Power BI để tự động phân tích và diễn giải số liệu biểu đồ thành Insight bằng ngôn ngữ tự nhiên.

#### 5. Khai phá dữ liệu (Data Mining)
- Khai phá các quy luật ẩn trên dữ liệu DDS (sau khi làm sạch và chuẩn bị tính năng).
- **Supervised Learning (Classification):** Triển khai mô hình *Logistic Regression* và *Decision Tree* để dự đoán khả năng chuyến bay bị trễ (Delay > 15 phút), trong đó mô hình Logistic Regression được chọn do đạt Recall cao nhằm tối ưu cảnh báo sớm rủi ro.
- **Unsupervised Learning (Clustering):** Sử dụng thuật toán *K-Means* và *Hierarchical Clustering* để phân 3 nhóm cụm các sân bay theo đặc điểm lưu lượng và mức độ rủi ro chậm trễ, hỗ trợ điều phối chiến lược.
