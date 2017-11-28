<!-- View Template --->

<cfinclude template="set_cookie.cfm">
<cfset cookie = #cookie.orderid#>

<!-- Does user want to delete item from cart? -->
<cfif isdefined('form.remove')>
	<cfquery name="removeitem" datasource="MOHAI" username="xmohai" password="xmohai">
		delete from store_seattlehistory_user_cart where recordid = #form.recordid#
	</cfquery>


<!-- Does user want to update qty of items ordered? -->
<cfelseif isdefined('form.update')>

	<cfset qtylength = #GetToken(form.item, 1, "|")#> <!-- Get Quantity Value -->
	<cfset qtylength = #LEN(qtylength)#> <!-- Get Quantity Char -->
	<cfset croplength = #LEN(form.item)# - #qtylength#> <!-- Crop Value -->
	<cfset Myitem = #RIGHT(form.item, croplength)#> <!-- Crop Item list of first value in list -->
	<cfset Myitem = '#form.qty##Myitem#'> <!-- Add new quantity to list -->

<!-- Insert New Value into Company Cart -->
	<cfquery name="updateitem" datasource="MOHAI" username="xmohai" password="xmohai">
		update store_seattlehistory_user_cart
			set item = '#Myitem#'
			where recordid = #form.recordid#
	</cfquery>

</cfif>


<!-- Get Shopping Cart Info -->
<cfquery name="getshoppingcart" datasource="MOHAI" username="xmohai" password="xmohai">
	select * from store_seattlehistory_user_cart 
	where orderid LIKE '#cookie#' order by recordid
</cfquery>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>Shopping Cart Contents</title>
	</head>
	<body bgcolor="#FFFFFF">

		<SCRIPT LANGUAGE="javascript">
		// This function calculates the 10% discount, if requested, excluding any memberships that might be in the order.
		function setnewDiscount() {
		var total_to_be_discounted = 0;
		var total_memberships = 0;
		// Loop through the forms, and then through the elements of each form.
		for (i = 0; i < document.forms.length; i++) {
				thisForm = document.forms[i]; // Create a form object
				for(j = 0; j < thisForm.elements.length; j++) {
					var this_name = thisForm.elements[j].name
					var this_value = thisForm.elements[j].value
						if (this_name == "product_id") {
							var next = (j + 1); // This finds the next form element after product_id.
							// Look for the "m" denoting a membershp product_id.
							// If an "m" not found, total up the non-membership prices to be discounted
							atPos = this_value.indexOf('m',0);
							if (atPos != 0) { // Check for store and photo purchase values
								var next_value = parseFloat(thisForm.elements[next].value);
								total_to_be_discounted += next_value;
							}
							// If an "m" found, total up the memberships
							if (atPos == 0) { // Check for membership subtotal values
								var next_value = parseFloat(thisForm.elements[next].value);
								total_memberships += next_value;
							} // end this if statement
						} // end this if statement
				} // end for loop
			} // end for loop

		// Calculate the total with discount, excluding the membership from the discount, and set the values in the form.
		var new_total = 0;
		if (document.myform.discount.checked) {
			discounted_amt = (total_to_be_discounted - (total_to_be_discounted * (10 / 100))); // Take 10% of the total price.
			new_total = (discounted_amt + total_memberships);
			document.myform.finalprice.value = FormatMoney((Math.ceil(new_total * 100) / 100)); // Round up to nearest penny and format.
		} else if (!document.myform.discount.checked) {
			new_total = (total_to_be_discounted + total_memberships);
			document.myform.finalprice.value = FormatMoney((Math.ceil(new_total * 100) / 100));
		}

		} // end this function
	
		// This function formats the displayed currency value properly.
		// Thanks to Mike Streeton, comp.lang.javascript
		function FormatMoney(MoneyValue) {
			if (MoneyValue == null)	{
				return "-";
			} else if (MoneyValue == 0) {
				return "POA";
			} else if (MoneyValue < 1) {
				return Math.round(MoneyValue*100)+"p";
			} else if (Math.floor(MoneyValue) == MoneyValue) {
				return MoneyValue+".00";
			} else if (Math.floor((Math.round(MoneyValue*100)/100)*10) == ((Math.round(MoneyValue*100)/100)*10)) {
				return (Math.round(MoneyValue*10)/10)+"0";
			} else {
				return (Math.round(MoneyValue*100)/100);
			}
		}
		</SCRIPT>
	
	<table cellspacing="0" cellpadding="0" border="1" width="100%">
		<tr>
			<td bgcolor="#E7E7E7" align="center" class="body">Quantity</td>
			<td bgcolor="#E7E7E7" align="center" class="body">Item Code</td>
			<td bgcolor="#E7E7E7" align="center" width="300" class="body">Description</td>
			<td bgcolor="#E7E7E7" align="center" width="75" class="body">Price</td>
			<td bgcolor="#E7E7E7" align="center" class="body">&nbsp;</td>
		</tr>
<cfset totalprice = 0.00>
<cfset shipping = 0.00>		
<cfset totalqty = 0>
<cfset cardqty = 0>
<cfset productlist = ''>
<cfset counter = 0>

<cfoutput query="getshoppingcart">
<cfset subtotal = "#GetToken(item, 4, '|')#">
<cfset ind_price = "#DollarFormat(GetToken(item, 4, '|'))#">
<cfset name = "#GetToken(item, 3, '|')#">
<cfset product_id = "#GetToken(item,2, '|')#">
<cfset qty = #GetToken(item, 1, '|')#>
<cfset totalqty = totalqty + qty>
<cfset subtotal = #Val(subtotal)# * #Val(qty)#>
		
		<tr>
			<td class="body" valign="middle"><form action="view_cart.cfm" method="post" name="update_cart#counter#">
				<input type="hidden" name="recordid" value="#recordid#">
				<input type="hidden" name="product_id" value="#product_id#">
				<input type="hidden" name="subtotal" value="#subtotal#">
				<input type="hidden" name="company" value="seattlehistory">
				<input type="hidden" name="return_url" value=#form.return_url#>
				<input type="hidden" name="update" value="update">
				<input type="text" value="#qty#" size="3" name="qty">
				<input type="image" border="0" name="update" value="update" src="images/update.gif" width="43" height="20" alt="Update">
				<input type="hidden" value="#item#" name="item">
				</form>
			</td>
			<td valign="middle" class="body">&nbsp;#product_id#</td>
			<td valign="middle" class="body">&nbsp;#name#</td>
			<td valign="middle" class="body">&nbsp;#DollarFormat(subtotal)#</td>
			<td class="body" valign="middle"><form action="view_cart.cfm" method="post" name="remove_cart#counter#"><br><br>
				<input type="hidden" name="recordid" value=#recordid#>
				<input type="hidden" name="company" value="seattlehistory">
				<input type="hidden" name="return_url" value=#form.return_url#>
				<input type="hidden" name="remove" value="remove">
				<input type="image" border="0" name="remove_image" value="remove_image" src="images/remove.gif" width="48" height="20" alt="Remove">
				</form>
			</td>
		</tr>

<CFIF ProductList IS NOT ''>
	<CFSET ProductList = ProductList & ",#product_id#|#qty#|#subtotal#">
<CFELSE>
	<CFSET ProductList = "#product_id#|#qty#|#subtotal#">
</CFIF>
<CFSET totalprice = #Val(totalprice)# + #Val(subtotal)#>
<cfset counter = (counter + 1)>
</cfoutput>

			<cfoutput>

			<form onSubmit="setnewDiscount()" action="store_checkout.cfm" method="POST" name="myform">
		<tr>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" align="right" class="body">Subtotal:</td>
			<td valign="middle" class="body">&nbsp;#DollarFormat(totalprice)#</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
		</tr>

		<tr>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>

			<td bgcolor="##E7E7E7" valign="middle" align="right" nowrap class="body"><INPUT TYPE="checkbox" VALUE="Y" NAME="discount" onClick="setnewDiscount()">&nbsp;I would like the member discount.&nbsp;<br>Not a member? <a href="http://66.118.148.54/mohai/involved_membership.cfm">Join now</a>!&nbsp;</td>

			<td class="body">&nbsp;(10%)</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
		</tr>
		<tr>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" align="right" class="body">Total Price:</td>
			<td class="body">&nbsp;<input type="text" name="finalprice" value="#DecimalFormat(totalprice)#" size="5"></td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
		</tr>

		<tr>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" align="right" class="body">I would like to support MOHAI with an additional tax-deductible donation of:&nbsp;</td>
			<td class="body">&nbsp;<input type="text" name="donation" value="" size="5"></td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
		</tr>

		<tr>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" class="body">&nbsp;</td>
			<td bgcolor="##E7E7E7" align="center" valign="middle" class="body"><br><br>

			<input type="hidden" name="company" value="seattlehistory">
			<input type="hidden" name="return_url" value=#form.return_url#>
			<input type="image" border="0" src="images/checkout.gif" width="53" height="20" alt="Checkout">
			</form>
			Click &quot;Checkout&quot; to purchase your selections.
			</cfoutput></td>
			<td class="body">&nbsp;</td>
			<td bgcolor="#E7E7E7" class="body">&nbsp;</td>
		</tr>

	</table>

	</body>
</html>
