CREATE SCHEMA [synthea]
GO

USE [synthea]
GO

/****** Object:  Table [Synthea].[devices]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[devices](
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[UDI] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[organizations]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[organizations](
	[Id] [nvarchar](50) NOT NULL,
	[NAME] [nvarchar](100) NOT NULL,
	[ADDRESS] [nvarchar](50) NOT NULL,
	[CITY] [nvarchar](50) NOT NULL,
	[STATE] [nvarchar](50) NOT NULL,
	[ZIP] [nvarchar](50) NOT NULL,
	[LAT] [float] NOT NULL,
	[LON] [float] NOT NULL,
	[PHONE] [nvarchar](50) NULL,
	[REVENUE] [float] NOT NULL,
	[UTILIZATION] [int] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[patients]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[patients](
	[id] [varchar](1000) NULL,
	[birthdate] [date] NULL,
	[deathdate] [date] NULL,
	[ssn] [varchar](100) NULL,
	[drivers] [varchar](100) NULL,
	[passport] [varchar](100) NULL,
	[prefix] [varchar](100) NULL,
	[first] [varchar](100) NULL,
	[last] [varchar](100) NULL,
	[suffix] [varchar](100) NULL,
	[maiden] [varchar](100) NULL,
	[marital] [varchar](100) NULL,
	[race] [varchar](100) NULL,
	[ethnicity] [varchar](100) NULL,
	[gender] [varchar](100) NULL,
	[birthplace] [varchar](100) NULL,
	[address] [varchar](100) NULL,
	[city] [varchar](100) NULL,
	[state] [varchar](100) NULL,
	[zip] [varchar](100) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[providers]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[providers](
	[Id] [nvarchar](50) NOT NULL,
	[ORGANIZATION] [nvarchar](50) NOT NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[GENDER] [nvarchar](50) NOT NULL,
	[SPECIALITY] [nvarchar](50) NOT NULL,
	[ADDRESS] [nvarchar](50) NOT NULL,
	[CITY] [nvarchar](50) NOT NULL,
	[STATE] [nvarchar](50) NOT NULL,
	[ZIP] [nvarchar](50) NOT NULL,
	[LAT] [float] NOT NULL,
	[LON] [float] NOT NULL,
	[UTILIZATION] [int] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[medications]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[medications](
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[PAYER] [nvarchar](50) NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL,
	[BASE_COST] [float] NULL,
	[PAYER_COVERAGE] [float] NULL,
	[DISPENSES] [int] NULL,
	[TOTALCOST] [float] NULL,
	[REASONCODE] [nvarchar](50) NULL,
	[REASONDESCRIPTION] [nvarchar](200) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[conditions]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[conditions](
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [float] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[procedures]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[procedures](
	[DATE] [datetime2](7) NOT NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](150) NOT NULL,
	[BASE_COST] [float] NULL,
	[REASONCODE] [nvarchar](100) NULL,
	[REASONDESCRIPTION] [nvarchar](150) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[careplans]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[careplans](
	[Id] [nvarchar](50) NOT NULL,
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [float] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[REASONCODE] [float] NULL,
	[REASONDESCRIPTION] [nvarchar](100) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[immunizations]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[immunizations](
	[DATE] [datetime2](7) NOT NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[BASE_COST] [float] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[encounters]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[encounters](
	[Id] [nvarchar](50) NOT NULL,
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ORGANIZATION] [nvarchar](50) NULL,
	[PROVIDER] [nvarchar](50) NULL,
	[PAYER] [nvarchar](50) NULL,
	[ENCOUNTERCLASS] [nvarchar](50) NULL,
	[CODE] [int] NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[BASE_ENCOUNTER_COST] [float] NULL,
	[TOTAL_CLAIM_COST] [float] NULL,
	[PAYER_COVERAGE] [float] NULL,
	[REASONCODE] [float] NULL,
	[REASONDESCRIPTION] [nvarchar](100) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[observations]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[observations](
	[DATE] [datetime2](7) NOT NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NULL,
	[CODE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL,
	[VALUE] [nvarchar](100) NULL,
	[UNITS] [nvarchar](50) NULL,
	[TYPE] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [Synthea].[allergies]    Script Date: 9/21/2021 7:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Synthea].[allergies](
	[START] [datetime2](7) NOT NULL,
	[STOP] [datetime2](7) NULL,
	[PATIENT] [nvarchar](50) NOT NULL,
	[ENCOUNTER] [nvarchar](50) NOT NULL,
	[CODE] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO


