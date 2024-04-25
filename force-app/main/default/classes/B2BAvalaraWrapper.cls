public with sharing class B2BAvalaraWrapper {

    public class Request {
        private String companyCode;
        private String type = 'SalesOrder';
        private String customerCode;
        private String currencyCode = '';
        private List<Line> lines;
        private Addresses addresses;
        private String date_x = Datetime.now().format('MM/dd/yyyy');
        private Boolean commit_x = false;


        public Request(String companyCode, String customerCode, List<Line> lines, Addresses addresses, String currencyCode) {
            this.companyCode = companyCode;
            this.customerCode = customerCode;
            this.lines = lines;
            this.addresses = addresses;
            this.currencyCode = currencyCode != null ? currencyCode : '';
        }
    }

    public class Line {
        private String description;
        private String number_x;
        private String amount;
        private String quantity;
        private String taxCode;

        public Line(String description, String number_x, String amount, String quantity, String taxCode) {
            this.description = description;
            this.number_x = number_x;
            this.amount = amount;
            this.quantity = quantity;
            this.taxCode = taxCode;
        }
    }

    public class Addresses {
        private Ship shipTo;

        public Addresses(Ship shipTo) {
            this.shipTo   = shipTo;
        }
    }

    public class Ship {
        private String line1;
        private String city;
        private String region;
        private String country;
        private String postalCode;

        public Ship(String line1, String city, String region, String country, String postalCode) {
            this.line1 = line1;
            this.city = city;
            this.region = region;
            this.country = country;
            this.postalCode = postalCode;
        }
    }

    public class Response {
        public String totalTax;
        public String currencyCode;
        public List<ResponseLines> lines;
        public Error error;
    }

    public class ResponseLines {
        public String tax;
        public String lineNumber;
        public List<Details> details;
    }

    public class Details {
        public String jurisdictionType;
        public String jurisType;
        public String rate;
        public String tax;
        public String taxableAmount;
        public String taxType;
        public String taxName;
        public String jurisName;
    }

    public class Error {
        public String target;
        public String message;
        public String code;
    }

    public class ResponseCompanies {
        public Integer recordsetCount;
	    public List<Company> value;
    }

    public class Company {
        public Integer id;
		public Integer accountId;
		public String companyCode;
    }

}