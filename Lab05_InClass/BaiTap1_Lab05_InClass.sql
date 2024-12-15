-- BAI TAP 1: Sinh viên hoàn thành Phần I bài tập QuanLyBanHang từ câu 11 đến 14. 

--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER trg_NGHD_NGDK
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN KHACHHANG K ON I.MAKH = K.MAKH
		WHERE I.NGHD < K.NGDK)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
CREATE TRIGGER trg_NGHD_NGVL
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN NHANVIEN N ON I.MANV = N.MANV
		WHERE I.NGHD < N.NGVL)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--13. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó. 
CREATE TRIGGER trg_trigia_hoadon
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN CTHD C ON C.SOHD = I.SOHD
		INNER JOIN SANPHAM S ON S.MASP = C.MASP 
		WHERE I.TRIGIA != C.SL*S.GIA)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--14. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua. 
CREATE TRIGGER trg_doanhso_khachhang
ON KHACHHANG
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		WHERE I.DOANHSO != (
		SELECT SUM(TRIGIA)
		FROM HOADON HD
		WHERE HD.MAKH = I.MAKH))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;