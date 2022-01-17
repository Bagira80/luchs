# Customization

_luchs_ is a CMake support framework that, in general, should be customized for your code-project,
company or product before using it for a new CMake project.

After forking the [original repository](https://github.com/Bagira80/luchs) of _luchs_ there are
some files that should be customized and committed to you fork. Afterwards all your projects
should be able to directly use your customized fork of _luchs_ without any further need for
customization.

In particular, the following files need customization:


## The template for company information

> **Location**: `framework/templates/company-info.cmake.in`

This file contains information that describes your company.

Some of the variables set in there will be used when running the resource compiler (on Windows)
for embedding additional information in a compiled library or executable. Others are used when
creating an install package for the build artifacts. And some are not used at all by _luchs_, but
can be used by the CMake project which uses _luchs_.

> **Note**: Of course, all variables from this file can be used by the CMake project directly.

* **`COMPANY_ID`** - A short identifier name for the company.
* **`COMPANY_NAME`** - The actual, official name of the company.
* **`COMPANY_FOUNDING_YEAR`** - The year at which the company was founded. This will be used in
  time ranges of copyright statements.
* **`COMPANY_EMAIL`** - The standard email address for contacting the company.
* **`COMPANY_SUPPORT_EMAIL`** - The email address for contacting the support department/team of
  the company.
* **`COMPANY_SUPPORT_NAME`** - The name of the support department/team of the company.
* **`COMPANY_GROUP_PACKAGE_NAME`** - The name of the group-package under which all packages of the
  company will be combined.


## The template for product information

> **Location**: `framework/templates/product-info.cmake.in`

This file contains information that describes your product.

> **Note**: Currently, _luchs_ is not using this information itself. But, of course, they can be
> used by the CMake project directly.

* **`product_name`** - The name of the product.
* **`product_description`** - The description of the product.
* **`product_homepage`** - The homepage of the product.
* **`product_version`** - The version of the product.


## The company's logo in the API documentation

> **Location**: `framework/doxygen/company-logo.svg`

The logo of the company which will be used in the API documentation which
[Doxygen](https://www.doxygen.nl) generates from the C/C++ sources of the CMake project.

