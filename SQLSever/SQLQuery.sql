﻿create database QuanLyKhachSan
go
--drop database QuanLyKhachSan
use QuanLyKhachSan
go

--Create table
create table DichVu(
	MaDichVu nvarchar(50) not null primary key,
	TenDichVu nvarchar(50),
	Gia float
)
create table Phong(
	MaPhong nvarchar(50) not null primary key,
	TenPhong nvarchar(50),
	LoaiPhong nvarchar(50),
	GiaPhong float,
	MoTa nvarchar(200),
	--Tinh trạng còn trống hay đã đặt phòng
	--0: còn trống
	--1: đã đặt
	TinhTrang bit default 0
)
create table HoaDonDichVuPhong(
	MaPhong nvarchar(50) not null,
	MaDichVu nvarchar(50) not null,
	SoLuong int,
	-------------------------
	--Thành tiền dịch vụ = SUM(Gia*SoLuong)
	--Giá(DichVu)
	--SoLuong(HoaDonDichVuPhong)
	ThanhTienDichVu float,--Dynamic
	-------------------------
	CONSTRAINT fk_maphong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
	CONSTRAINT fk_madichvu FOREIGN KEY (MaDichVu) REFERENCES DichVu(MaDichVu)
)
create table KhachHang(
	MaKhachHang nvarchar(50) not null primary key,
	TenKhachHang nvarchar(50) not null,
	CMT nvarchar(50) not null,
	SDT nvarchar(10) not null,
	Gmail nvarchar(50)
)

create table NhanVien(
	MaNhanVien nvarchar(50) not null primary key,
	HoTen nvarchar(50) not null,
	Pwd nvarchar(50) not null,
	--Chức vụ
	--0: nhân viên bình thường
	--1: quản lý
	ChucVu bit not null,
	--Giới tính
	GioiTinh char(3),
	CMT nvarchar(50) not null,
	SDT char(10) not null,
	Gmail nvarchar(50),
	DiaChi nvarchar(200)
)

create table HoaDonThanhToan(
	MaHoaDon nvarchar(50) not null primary key,
	NgayThanhToan datetime,
	--Hình thức thanh toán
	--0: tiền mặt
	--1: chuyển khoản
	HinhThucThanhToan bit,

	---------------------------------------------
	--Thành tiền phòng = số ngày ở(PhieuDatPhong) * giá phòng(Phong)
	ThanhTienPhong float,--Dynamic
	--Tổng thanh toán = SUM(ThanhTienDichVuPhong) (HoaDonDichVuPhong) + ThanhTienPhong
	TongThanhToan float,--Dynamic
	---------------------------------------------

	GhiChu nvarchar(200)
)
create table PhieuDatPhong(
	MaDatPhong nvarchar(50) not null primary key,
	-----FOREIGN KEY
	MaNV nvarchar(50) not null,
	MaPhong nvarchar(50) not null,
	IDNguoiDatPhong nvarchar(50) not null,
	MaHoaDon nvarchar(50) not null,
	-----
	NgayDatPhong datetime,
	NgayCheckIn datetime,
	NgayCheckOut datetime,
	SoNguoi int,
	GhiChu nvarchar(50)

	CONSTRAINT fk_nv FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNhanVien),
	CONSTRAINT fk_mp FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
	CONSTRAINT fk_kh FOREIGN KEY (IDNguoiDatPhong) REFERENCES KhachHang(MaKhachHang),
	CONSTRAINT fk_hd FOREIGN KEY (MaHoaDon) REFERENCES HoaDonThanhToan(MaHoaDon)
)

--INSERT DATA
--DICH VU
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV001',N'Nước khoáng lavie 350ml',3500)
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV002',N'Nước suối Aquafina 500ml',6000)
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV003',N'Nước ngọt 7 Up 330ml',8500)
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV004',N'Nước ngọt Pepsi 320ml',10600)
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV005',N'Nước ngọt Cocacola Zero 600ml',10000)
INSERT INTO DichVu (MaDichVu,TenDichVu,Gia)
values(N'DV006',N'Khăn giấy',3000)

--HOA DON DICH VU PHONG
--create trigger insert
go
CREATE TRIGGER trigger_hddvphong on HoaDonDichVuPhong
after insert
as 
	--khai báo biến giá và mã dv
	declare @gia float, @madv varchar(50), @map varchar(50)
	--lấy dữ liệu từ insert
	select @madv = MaDichVu, @map = MaPhong
	from inserted 
	--lấy dữ liệu từ bảng Dịch vụ
	select @gia = Gia 
	from DichVu
	where MaDichVu like @madv

	UPDATE HoaDonDichVuPhong
	set ThanhTienDichVu = @gia * SoLuong
	where MaDichVu = @madv and MaPhong = @map
go

INSERT INTO Phong (MaPhong) values(N'P001')
INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P001',N'DV001',1)
INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P001',N'DV003',5)
INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P001',N'DV004',7)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P002',N'DV004',4)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P002',N'DV002',9)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P002',N'DV003',3)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P003',N'DV006',11)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P004',N'DV005',23)
--INSERT INTO HoaDonDichVuPhong (MaPhong,MaDichVu,SoLuong) values(N'P004',N'DV003',15)
