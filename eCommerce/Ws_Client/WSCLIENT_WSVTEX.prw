#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc?wsdl
Gerado em        05/02/19 15:40:09
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
* Generated using &HTTPAUTH setting.
=============================================================================== */

User Function _JMMMSNY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSService
------------------------------------------------------------------------------- */

WSCLIENT WSVTex

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD StockKeepingUnitInsertUpdate
	WSMETHOD StockKeepingUnitPriceUpdate
	WSMETHOD StockKeepingUnitPriceUpdateByRefId
	WSMETHOD StockKeepingUnitGet
	WSMETHOD StockKeepingUnitGetByManufacturerCode
	WSMETHOD StockKeepingUnitGetByRefId
	WSMETHOD ProductInsertUpdate
	WSMETHOD ProductGet
	WSMETHOD ProductGetByRefId
	WSMETHOD ProductGetSimilarCategory
	WSMETHOD ProductGetAllFromUpdatedDateAndId
	WSMETHOD ProductActive
	WSMETHOD StockKeepingUnitKitListByParent
	WSMETHOD StockKeepingUnitKitListBySkuId
	WSMETHOD StockKeepingUnitKitDeleteByParent
	WSMETHOD StockKeepingUnitKitInsertUpdate
	WSMETHOD StockKeepingUnitActive
	WSMETHOD StockKeepingUnitGetAllByProduct
	WSMETHOD StockKeepingUnitGetByEan
	WSMETHOD ServiceGet
	WSMETHOD ServicePriceGet
	WSMETHOD ServicePriceList
	WSMETHOD ServiceInsertUpdate
	WSMETHOD ServicePriceInsertUpdate
	WSMETHOD StockKeepingUnitServiceGet
	WSMETHOD StockKeepingUnitServiceList
	WSMETHOD StockKeepingUnitServiceInsertUpdate
	WSMETHOD BrandGet
	WSMETHOD BrandGetByName
	WSMETHOD BrandInsertUpdate
	WSMETHOD CategoryGet
	WSMETHOD CategoryGetByName
	WSMETHOD CategoryInsertUpdate
	WSMETHOD ImageServiceCopyAllImagesFromSkuToSku
	WSMETHOD ImageServiceInsertUpdate
	WSMETHOD ImageInsertUpdate
	WSMETHOD ImageListByStockKeepingUnitId
	WSMETHOD StockKeepingUnitImageRemove
	WSMETHOD StockKeepingUnitImageRemoveByName
	WSMETHOD StockKeepingUnitEspecificationListBySkuId
	WSMETHOD ProductEspecificationListByProductId
	WSMETHOD StockKeepingUnitComplementInsertUpdate
	WSMETHOD ProductEspecificationInsert
	WSMETHOD ProductEspecificationInsertByList
	WSMETHOD ProductEspecificationInsertByFieldId
	WSMETHOD ProductEspecificationInsertByListFieldIds
	WSMETHOD ProductEspecificationTextInsertByFieldId
	WSMETHOD StockKeepingUnitEspecificationInsertByList
	WSMETHOD StockKeepingUnitEspecificationInsert
	WSMETHOD ProductSetSimilarCategory
	WSMETHOD StoreList
	WSMETHOD StoreGet
	WSMETHOD StockKeepingUnitEspecificationInsertByFieldId
	WSMETHOD GiftCardInsertUpdate
	WSMETHOD GiftCardTransactionItemInsert
	WSMETHOD GiftListGet
	WSMETHOD GiftListGetByClientEmail
	WSMETHOD GiftListGetByClientCpf
	WSMETHOD GiftListGetType
	WSMETHOD GiftListGetByCreatedDate
	WSMETHOD GiftListGetAllFromCreatedDateAndId
	WSMETHOD GiftListGetAllBetweenEventDateIntervalAndId
	WSMETHOD GiftListGetByModifiedDate
	WSMETHOD GiftListGetAllFromModifiedDateAndId
	WSMETHOD GiftListGetByGifted
	WSMETHOD GiftListInsertUpdate
	WSMETHOD GiftListV2Filters
	WSMETHOD GiftListSearch
	WSMETHOD GiftListSearchWithSurname
	WSMETHOD GiftListMemberInsertUpdate
	WSMETHOD GiftListMemberDelete
	WSMETHOD GiftListSkuInsert
	WSMETHOD GiftListSkuGet
	WSMETHOD GiftListSkuSetPurchased
	WSMETHOD GiftListSkuDeleteByList
	WSMETHOD GiftListSkuDelete
	WSMETHOD GiftCardGet
	WSMETHOD GiftCardGetByRedeptionCode
	WSMETHOD IntegrationLogErrorInsertUpdate
	WSMETHOD IntegrationErrorCheckInstanceExists

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSstockKeepingUnitVO     AS Service_StockKeepingUnitDTO
	WSDATA   oWSStockKeepingUnitInsertUpdateResult AS Service_StockKeepingUnitDTO
	WSDATA   nstockKeepintUnitId       AS int
	WSDATA   nprice                    AS decimal
	WSDATA   nlistPrice                AS decimal
	WSDATA   ncostPrice                AS decimal
	WSDATA   cstockKeepintUnitRefId    AS string
	WSDATA   nid                       AS int
	WSDATA   oWSStockKeepingUnitGetResult AS Service_StockKeepingUnitDTO
	WSDATA   cmanufacturer             AS string
	WSDATA   oWSStockKeepingUnitGetByManufacturerCodeResult AS Service_ArrayOfStockKeepingUnitDTO
	WSDATA   crefId                    AS string
	WSDATA   oWSStockKeepingUnitGetByRefIdResult AS Service_StockKeepingUnitDTO
	WSDATA   oWSproductVO              AS Service_ProductDTO
	WSDATA   oWSProductInsertUpdateResult AS Service_ProductDTO
	WSDATA   nidProduct                AS int
	WSDATA   oWSProductGetResult       AS Service_ProductDTO
	WSDATA   oWSProductGetByRefIdResult AS Service_ProductDTO
	WSDATA   nproductId                AS int
	WSDATA   oWSProductGetSimilarCategoryResult AS Service_ArrayOfint
	WSDATA   cdateUpdated              AS dateTime
	WSDATA   ntopRows                  AS int
	WSDATA   oWSProductGetAllFromUpdatedDateAndIdResult AS Service_ArrayOfProductDTO
	WSDATA   nidSkuParent              AS int
	WSDATA   oWSStockKeepingUnitKitListByParentResult AS Service_ArrayOfStockKeepingUnitKitDTO
	WSDATA   nidSku                    AS int
	WSDATA   oWSStockKeepingUnitKitListBySkuIdResult AS Service_ArrayOfStockKeepingUnitKitDTO
	WSDATA   oWSstockKeepingUnitKit    AS Service_StockKeepingUnitKitDTO
	WSDATA   oWSStockKeepingUnitKitInsertUpdateResult AS Service_StockKeepingUnitKitDTO
	WSDATA   nstockKeepingUnitKitId    AS int
	WSDATA   nidStockKeepingUnit       AS int
	WSDATA   oWSStockKeepingUnitGetAllByProductResult AS Service_ArrayOfStockKeepingUnitDTO
	WSDATA   cEAN13                    AS string
	WSDATA   oWSStockKeepingUnitGetByEanResult AS Service_StockKeepingUnitDTO
	WSDATA   nidService                AS int
	WSDATA   oWSServiceGetResult       AS Service_ServiceDTO
	WSDATA   nidServicePrice           AS int
	WSDATA   oWSServicePriceGetResult  AS Service_ServicePriceDTO
	WSDATA   oWSServicePriceListResult AS Service_ArrayOfServicePriceDTO
	WSDATA   oWSservice                AS Service_ServiceDTO
	WSDATA   oWSServiceInsertUpdateResult AS Service_ServiceDTO
	WSDATA   nserviceId                AS int
	WSDATA   oWSservicePrice           AS Service_ServicePriceDTO
	WSDATA   oWSServicePriceInsertUpdateResult AS Service_ServicePriceDTO
	WSDATA   nservicePriceId           AS int
	WSDATA   nidStockKeepingUnitService AS int
	WSDATA   oWSStockKeepingUnitServiceGetResult AS Service_StockKeepingUnitServiceDTO
	WSDATA   oWSStockKeepingUnitServiceListResult AS Service_ArrayOfStockKeepingUnitServiceDTO
	WSDATA   oWSstockKeepingUnitService AS Service_StockKeepingUnitServiceDTO
	WSDATA   oWSStockKeepingUnitServiceInsertUpdateResult AS Service_StockKeepingUnitServiceDTO
	WSDATA   nstockKeepingUnitServiceId AS int
	WSDATA   nidBrand                  AS int
	WSDATA   oWSBrandGetResult         AS Service_BrandDTO
	WSDATA   cnameBrand                AS string
	WSDATA   oWSBrandGetByNameResult   AS Service_BrandDTO
	WSDATA   oWSbrand                  AS Service_BrandDTO
	WSDATA   oWSBrandInsertUpdateResult AS Service_BrandDTO
	WSDATA   nidCategory               AS int
	WSDATA   oWSCategoryGetResult      AS Service_CategoryDTO
	WSDATA   cnameCategory             AS string
	WSDATA   oWSCategoryGetByNameResult AS Service_CategoryDTO
	WSDATA   oWScategory               AS Service_CategoryDTO
	WSDATA   oWSCategoryInsertUpdateResult AS Service_CategoryDTO
	WSDATA   nstockKeepingUnitIdFrom   AS int
	WSDATA   nstockKeepingUnitIdTo     AS int
	WSDATA   curlImage                 AS string
	WSDATA   cimageName                AS string
	WSDATA   nstockKeepingUnitId       AS int
	WSDATA   nfileId                   AS int
	WSDATA   oWSimage                  AS Service_ImageDTO
	WSDATA   nArchiveTypeId            AS int
	WSDATA   oWSImageListByStockKeepingUnitIdResult AS Service_ArrayOfImageDTO
	WSDATA   nskuId                    AS int
	WSDATA   oWSStockKeepingUnitEspecificationListBySkuIdResult AS Service_ArrayOfFieldDTO
	WSDATA   oWSProductEspecificationListByProductIdResult AS Service_ArrayOfFieldDTO
	WSDATA   oWSobjStockKeepingUnitComplementDTO AS Service_StockKeepingUnitComplementDTO
	WSDATA   cfieldName                AS string
	WSDATA   oWSfieldValues            AS Service_ArrayOfstring
	WSDATA   oWSlistProductFieldName   AS Service_ArrayOfProductFieldNameDTO
	WSDATA   nfieldId                  AS int
	WSDATA   oWSlistStockKeepingUnitEspecificationFieldId AS Service_ArrayOfProductFieldIdDTO
	WSDATA   cDescription              AS string
	WSDATA   oWSlistStockKeepingUnitName AS Service_ArrayOfStockKeepingUnitFieldNameDTO
	WSDATA   ncategoryId               AS int
	WSDATA   oWSStoreListResult        AS Service_ArrayOfStoreDTO
	WSDATA   nstoreId                  AS int
	WSDATA   oWSStoreGetResult         AS Service_StoreDTO
	WSDATA   oWSgiftcard               AS Service_GiftCardDTO
	WSDATA   oWSGiftCardInsertUpdateResult AS Service_GiftCardDTO
	WSDATA   oWSgiftCardTransactionItem AS Service_GiftCardTransactionItemDTO
	WSDATA   lGiftCardTransactionItemInsertResult AS boolean
	WSDATA   nidGiftList               AS int
	WSDATA   oWSGiftListGetResult      AS Service_GiftListDTO
	WSDATA   cclientEmail              AS string
	WSDATA   oWSGiftListGetByClientEmailResult AS Service_ArrayOfGiftListDTO
	WSDATA   cclientCpfCnpj            AS string
	WSDATA   oWSGiftListGetByClientCpfResult AS Service_ArrayOfGiftListDTO
	WSDATA   ngiftListTypeId           AS int
	WSDATA   oWSGiftListGetTypeResult  AS Service_GiftListTypeDTO
	WSDATA   ccreatedDate              AS dateTime
	WSDATA   oWSGiftListGetByCreatedDateResult AS Service_ArrayOfGiftListDTO
	WSDATA   nstartingGiftListId       AS int
	WSDATA   oWSGiftListGetAllFromCreatedDateAndIdResult AS Service_ArrayOfGiftListDTO
	WSDATA   ceventDateBegin           AS dateTime
	WSDATA   ceventDateEnd             AS dateTime
	WSDATA   oWSGiftListGetAllBetweenEventDateIntervalAndIdResult AS Service_ArrayOfGiftListDTO
	WSDATA   cmodifiedDate             AS dateTime
	WSDATA   oWSGiftListGetByModifiedDateResult AS Service_ArrayOfGiftListDTO
	WSDATA   oWSGiftListGetAllFromModifiedDateAndIdResult AS Service_ArrayOfGiftListDTO
	WSDATA   cgifted                   AS string
	WSDATA   oWSGiftListGetByGiftedResult AS Service_ArrayOfGiftListDTO
	WSDATA   oWSgiftList               AS Service_GiftListDTO
	WSDATA   oWSGiftListInsertUpdateResult AS Service_GiftListDTO
	WSDATA   ngiftListId               AS int
	WSDATA   nclientId                 AS int
	WSDATA   ceventDateSince           AS dateTime
	WSDATA   ceventDateUntil           AS dateTime
	WSDATA   lisActive                 AS boolean
	WSDATA   oWSGiftListV2FiltersResult AS Service_ArrayOfGiftListDTO
	WSDATA   cclientName               AS string
	WSDATA   ceventLocation            AS string
	WSDATA   ceventCity                AS string
	WSDATA   ceventDate                AS dateTime
	WSDATA   oWSGiftListSearchResult   AS Service_ArrayOfGiftListDTO
	WSDATA   cclientSurname            AS string
	WSDATA   oWSGiftListSearchWithSurnameResult AS Service_ArrayOfGiftListDTO
	WSDATA   oWSgiftListMember         AS Service_ArrayOfGiftListMemberDTO
	WSDATA   oWSGiftListMemberInsertUpdateResult AS Service_ArrayOfGiftListMemberDTO
	WSDATA   nGiftListMemberId         AS int
	WSDATA   oWSgiftListSku            AS Service_GiftListStockKeepingUnitDTO
	WSDATA   oWSGiftListSkuInsertResult AS Service_GiftListStockKeepingUnitDTO
	WSDATA   oWSGiftListSkuGetResult   AS Service_ArrayOfGiftListStockKeepingUnitDTO
	WSDATA   nQuantity                 AS int
	WSDATA   norderId                  AS int
	WSDATA   oWSskuQuantity            AS Service_ArrayOfStockKeepingUnitQuantityDTO
	WSDATA   oWSGiftCardGetResult      AS Service_GiftCardDTO
	WSDATA   credeptionCode            AS string
	WSDATA   oWSGiftCardGetByRedeptionCodeResult AS Service_GiftCardDTO
	WSDATA   oWSerrorType              AS Service_ErrorType
	WSDATA   cinstance                 AS string
	WSDATA   cerror                    AS string
	WSDATA   cerrorDetail              AS string
	WSDATA   lIntegrationErrorCheckInstanceExistsResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSVTex
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20181218 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSVTex
	::oWSstockKeepingUnitVO := Service_STOCKKEEPINGUNITDTO():New()
	::oWSStockKeepingUnitInsertUpdateResult := Service_STOCKKEEPINGUNITDTO():New()
	::oWSStockKeepingUnitGetResult := Service_STOCKKEEPINGUNITDTO():New()
	::oWSStockKeepingUnitGetByManufacturerCodeResult := Service_ARRAYOFSTOCKKEEPINGUNITDTO():New()
	::oWSStockKeepingUnitGetByRefIdResult := Service_STOCKKEEPINGUNITDTO():New()
	::oWSproductVO       := Service_PRODUCTDTO():New()
	::oWSProductInsertUpdateResult := Service_PRODUCTDTO():New()
	::oWSProductGetResult := Service_PRODUCTDTO():New()
	::oWSProductGetByRefIdResult := Service_PRODUCTDTO():New()
	::oWSProductGetSimilarCategoryResult := Service_ARRAYOFINT():New()
	::oWSProductGetAllFromUpdatedDateAndIdResult := Service_ARRAYOFPRODUCTDTO():New()
	::oWSStockKeepingUnitKitListByParentResult := Service_ARRAYOFSTOCKKEEPINGUNITKITDTO():New()
	::oWSStockKeepingUnitKitListBySkuIdResult := Service_ARRAYOFSTOCKKEEPINGUNITKITDTO():New()
	::oWSstockKeepingUnitKit := Service_STOCKKEEPINGUNITKITDTO():New()
	::oWSStockKeepingUnitKitInsertUpdateResult := Service_STOCKKEEPINGUNITKITDTO():New()
	::oWSStockKeepingUnitGetAllByProductResult := Service_ARRAYOFSTOCKKEEPINGUNITDTO():New()
	::oWSStockKeepingUnitGetByEanResult := Service_STOCKKEEPINGUNITDTO():New()
	::oWSServiceGetResult := Service_SERVICEDTO():New()
	::oWSServicePriceGetResult := Service_SERVICEPRICEDTO():New()
	::oWSServicePriceListResult := Service_ARRAYOFSERVICEPRICEDTO():New()
	::oWSservice         := Service_SERVICEDTO():New()
	::oWSServiceInsertUpdateResult := Service_SERVICEDTO():New()
	::oWSservicePrice    := Service_SERVICEPRICEDTO():New()
	::oWSServicePriceInsertUpdateResult := Service_SERVICEPRICEDTO():New()
	::oWSStockKeepingUnitServiceGetResult := Service_STOCKKEEPINGUNITSERVICEDTO():New()
	::oWSStockKeepingUnitServiceListResult := Service_ARRAYOFSTOCKKEEPINGUNITSERVICEDTO():New()
	::oWSstockKeepingUnitService := Service_STOCKKEEPINGUNITSERVICEDTO():New()
	::oWSStockKeepingUnitServiceInsertUpdateResult := Service_STOCKKEEPINGUNITSERVICEDTO():New()
	::oWSBrandGetResult  := Service_BRANDDTO():New()
	::oWSBrandGetByNameResult := Service_BRANDDTO():New()
	::oWSbrand           := Service_BRANDDTO():New()
	::oWSBrandInsertUpdateResult := Service_BRANDDTO():New()
	::oWSCategoryGetResult := Service_CATEGORYDTO():New()
	::oWSCategoryGetByNameResult := Service_CATEGORYDTO():New()
	::oWScategory        := Service_CATEGORYDTO():New()
	::oWSCategoryInsertUpdateResult := Service_CATEGORYDTO():New()
	::oWSimage           := Service_IMAGEDTO():New()
	::oWSImageListByStockKeepingUnitIdResult := Service_ARRAYOFIMAGEDTO():New()
	::oWSStockKeepingUnitEspecificationListBySkuIdResult := Service_ARRAYOFFIELDDTO():New()
	::oWSProductEspecificationListByProductIdResult := Service_ARRAYOFFIELDDTO():New()
	::oWSobjStockKeepingUnitComplementDTO := Service_STOCKKEEPINGUNITCOMPLEMENTDTO():New()
	::oWSfieldValues     := Service_ARRAYOFSTRING():New()
	::oWSlistProductFieldName := Service_ARRAYOFPRODUCTFIELDNAMEDTO():New()
	::oWSlistStockKeepingUnitEspecificationFieldId := Service_ARRAYOFPRODUCTFIELDIDDTO():New()
	::oWSlistStockKeepingUnitName := Service_ARRAYOFSTOCKKEEPINGUNITFIELDNAMEDTO():New()
	::oWSStoreListResult := Service_ARRAYOFSTOREDTO():New()
	::oWSStoreGetResult  := Service_STOREDTO():New()
	::oWSgiftcard        := Service_GIFTCARDDTO():New()
	::oWSGiftCardInsertUpdateResult := Service_GIFTCARDDTO():New()
	::oWSgiftCardTransactionItem := Service_GIFTCARDTRANSACTIONITEMDTO():New()
	::oWSGiftListGetResult := Service_GIFTLISTDTO():New()
	::oWSGiftListGetByClientEmailResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetByClientCpfResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetTypeResult := Service_GIFTLISTTYPEDTO():New()
	::oWSGiftListGetByCreatedDateResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetAllFromCreatedDateAndIdResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetAllBetweenEventDateIntervalAndIdResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetByModifiedDateResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetAllFromModifiedDateAndIdResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListGetByGiftedResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSgiftList        := Service_GIFTLISTDTO():New()
	::oWSGiftListInsertUpdateResult := Service_GIFTLISTDTO():New()
	::oWSGiftListV2FiltersResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListSearchResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSGiftListSearchWithSurnameResult := Service_ARRAYOFGIFTLISTDTO():New()
	::oWSgiftListMember  := Service_ARRAYOFGIFTLISTMEMBERDTO():New()
	::oWSGiftListMemberInsertUpdateResult := Service_ARRAYOFGIFTLISTMEMBERDTO():New()
	::oWSgiftListSku     := Service_GIFTLISTSTOCKKEEPINGUNITDTO():New()
	::oWSGiftListSkuInsertResult := Service_GIFTLISTSTOCKKEEPINGUNITDTO():New()
	::oWSGiftListSkuGetResult := Service_ARRAYOFGIFTLISTSTOCKKEEPINGUNITDTO():New()
	::oWSskuQuantity     := Service_ARRAYOFSTOCKKEEPINGUNITQUANTITYDTO():New()
	::oWSGiftCardGetResult := Service_GIFTCARDDTO():New()
	::oWSGiftCardGetByRedeptionCodeResult := Service_GIFTCARDDTO():New()
	::oWSerrorType       := Service_ERRORTYPE():New()
Return

WSMETHOD RESET WSCLIENT WSVTex
	::oWSstockKeepingUnitVO := NIL 
	::oWSStockKeepingUnitInsertUpdateResult := NIL 
	::nstockKeepintUnitId := NIL 
	::nprice             := NIL 
	::nlistPrice         := NIL 
	::ncostPrice         := NIL 
	::cstockKeepintUnitRefId := NIL 
	::nid                := NIL 
	::oWSStockKeepingUnitGetResult := NIL 
	::cmanufacturer      := NIL 
	::oWSStockKeepingUnitGetByManufacturerCodeResult := NIL 
	::crefId             := NIL 
	::oWSStockKeepingUnitGetByRefIdResult := NIL 
	::oWSproductVO       := NIL 
	::oWSProductInsertUpdateResult := NIL 
	::nidProduct         := NIL 
	::oWSProductGetResult := NIL 
	::oWSProductGetByRefIdResult := NIL 
	::nproductId         := NIL 
	::oWSProductGetSimilarCategoryResult := NIL 
	::cdateUpdated       := NIL 
	::ntopRows           := NIL 
	::oWSProductGetAllFromUpdatedDateAndIdResult := NIL 
	::nidSkuParent       := NIL 
	::oWSStockKeepingUnitKitListByParentResult := NIL 
	::nidSku             := NIL 
	::oWSStockKeepingUnitKitListBySkuIdResult := NIL 
	::oWSstockKeepingUnitKit := NIL 
	::oWSStockKeepingUnitKitInsertUpdateResult := NIL 
	::nstockKeepingUnitKitId := NIL 
	::nidStockKeepingUnit := NIL 
	::oWSStockKeepingUnitGetAllByProductResult := NIL 
	::cEAN13             := NIL 
	::oWSStockKeepingUnitGetByEanResult := NIL 
	::nidService         := NIL 
	::oWSServiceGetResult := NIL 
	::nidServicePrice    := NIL 
	::oWSServicePriceGetResult := NIL 
	::oWSServicePriceListResult := NIL 
	::oWSservice         := NIL 
	::oWSServiceInsertUpdateResult := NIL 
	::nserviceId         := NIL 
	::oWSservicePrice    := NIL 
	::oWSServicePriceInsertUpdateResult := NIL 
	::nservicePriceId    := NIL 
	::nidStockKeepingUnitService := NIL 
	::oWSStockKeepingUnitServiceGetResult := NIL 
	::oWSStockKeepingUnitServiceListResult := NIL 
	::oWSstockKeepingUnitService := NIL 
	::oWSStockKeepingUnitServiceInsertUpdateResult := NIL 
	::nstockKeepingUnitServiceId := NIL 
	::nidBrand           := NIL 
	::oWSBrandGetResult  := NIL 
	::cnameBrand         := NIL 
	::oWSBrandGetByNameResult := NIL 
	::oWSbrand           := NIL 
	::oWSBrandInsertUpdateResult := NIL 
	::nidCategory        := NIL 
	::oWSCategoryGetResult := NIL 
	::cnameCategory      := NIL 
	::oWSCategoryGetByNameResult := NIL 
	::oWScategory        := NIL 
	::oWSCategoryInsertUpdateResult := NIL 
	::nstockKeepingUnitIdFrom := NIL 
	::nstockKeepingUnitIdTo := NIL 
	::curlImage          := NIL 
	::cimageName         := NIL 
	::nstockKeepingUnitId := NIL 
	::nfileId            := NIL 
	::oWSimage           := NIL 
	::nArchiveTypeId     := NIL 
	::oWSImageListByStockKeepingUnitIdResult := NIL 
	::nskuId             := NIL 
	::oWSStockKeepingUnitEspecificationListBySkuIdResult := NIL 
	::oWSProductEspecificationListByProductIdResult := NIL 
	::oWSobjStockKeepingUnitComplementDTO := NIL 
	::cfieldName         := NIL 
	::oWSfieldValues     := NIL 
	::oWSlistProductFieldName := NIL 
	::nfieldId           := NIL 
	::oWSlistStockKeepingUnitEspecificationFieldId := NIL 
	::cDescription       := NIL 
	::oWSlistStockKeepingUnitName := NIL 
	::ncategoryId        := NIL 
	::oWSStoreListResult := NIL 
	::nstoreId           := NIL 
	::oWSStoreGetResult  := NIL 
	::oWSgiftcard        := NIL 
	::oWSGiftCardInsertUpdateResult := NIL 
	::oWSgiftCardTransactionItem := NIL 
	::lGiftCardTransactionItemInsertResult := NIL 
	::nidGiftList        := NIL 
	::oWSGiftListGetResult := NIL 
	::cclientEmail       := NIL 
	::oWSGiftListGetByClientEmailResult := NIL 
	::cclientCpfCnpj     := NIL 
	::oWSGiftListGetByClientCpfResult := NIL 
	::ngiftListTypeId    := NIL 
	::oWSGiftListGetTypeResult := NIL 
	::ccreatedDate       := NIL 
	::oWSGiftListGetByCreatedDateResult := NIL 
	::nstartingGiftListId := NIL 
	::oWSGiftListGetAllFromCreatedDateAndIdResult := NIL 
	::ceventDateBegin    := NIL 
	::ceventDateEnd      := NIL 
	::oWSGiftListGetAllBetweenEventDateIntervalAndIdResult := NIL 
	::cmodifiedDate      := NIL 
	::oWSGiftListGetByModifiedDateResult := NIL 
	::oWSGiftListGetAllFromModifiedDateAndIdResult := NIL 
	::cgifted            := NIL 
	::oWSGiftListGetByGiftedResult := NIL 
	::oWSgiftList        := NIL 
	::oWSGiftListInsertUpdateResult := NIL 
	::ngiftListId        := NIL 
	::nclientId          := NIL 
	::ceventDateSince    := NIL 
	::ceventDateUntil    := NIL 
	::lisActive          := NIL 
	::oWSGiftListV2FiltersResult := NIL 
	::cclientName        := NIL 
	::ceventLocation     := NIL 
	::ceventCity         := NIL 
	::ceventDate         := NIL 
	::oWSGiftListSearchResult := NIL 
	::cclientSurname     := NIL 
	::oWSGiftListSearchWithSurnameResult := NIL 
	::oWSgiftListMember  := NIL 
	::oWSGiftListMemberInsertUpdateResult := NIL 
	::nGiftListMemberId  := NIL 
	::oWSgiftListSku     := NIL 
	::oWSGiftListSkuInsertResult := NIL 
	::oWSGiftListSkuGetResult := NIL 
	::nQuantity          := NIL 
	::norderId           := NIL 
	::oWSskuQuantity     := NIL 
	::oWSGiftCardGetResult := NIL 
	::credeptionCode     := NIL 
	::oWSGiftCardGetByRedeptionCodeResult := NIL 
	::oWSerrorType       := NIL 
	::cinstance          := NIL 
	::cerror             := NIL 
	::cerrorDetail       := NIL 
	::lIntegrationErrorCheckInstanceExistsResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSVTex
Local oClone := WSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSstockKeepingUnitVO :=  IIF(::oWSstockKeepingUnitVO = NIL , NIL ,::oWSstockKeepingUnitVO:Clone() )
	oClone:oWSStockKeepingUnitInsertUpdateResult :=  IIF(::oWSStockKeepingUnitInsertUpdateResult = NIL , NIL ,::oWSStockKeepingUnitInsertUpdateResult:Clone() )
	oClone:nstockKeepintUnitId := ::nstockKeepintUnitId
	oClone:nprice        := ::nprice
	oClone:nlistPrice    := ::nlistPrice
	oClone:ncostPrice    := ::ncostPrice
	oClone:cstockKeepintUnitRefId := ::cstockKeepintUnitRefId
	oClone:nid           := ::nid
	oClone:oWSStockKeepingUnitGetResult :=  IIF(::oWSStockKeepingUnitGetResult = NIL , NIL ,::oWSStockKeepingUnitGetResult:Clone() )
	oClone:cmanufacturer := ::cmanufacturer
	oClone:oWSStockKeepingUnitGetByManufacturerCodeResult :=  IIF(::oWSStockKeepingUnitGetByManufacturerCodeResult = NIL , NIL ,::oWSStockKeepingUnitGetByManufacturerCodeResult:Clone() )
	oClone:crefId        := ::crefId
	oClone:oWSStockKeepingUnitGetByRefIdResult :=  IIF(::oWSStockKeepingUnitGetByRefIdResult = NIL , NIL ,::oWSStockKeepingUnitGetByRefIdResult:Clone() )
	oClone:oWSproductVO  :=  IIF(::oWSproductVO = NIL , NIL ,::oWSproductVO:Clone() )
	oClone:oWSProductInsertUpdateResult :=  IIF(::oWSProductInsertUpdateResult = NIL , NIL ,::oWSProductInsertUpdateResult:Clone() )
	oClone:nidProduct    := ::nidProduct
	oClone:oWSProductGetResult :=  IIF(::oWSProductGetResult = NIL , NIL ,::oWSProductGetResult:Clone() )
	oClone:oWSProductGetByRefIdResult :=  IIF(::oWSProductGetByRefIdResult = NIL , NIL ,::oWSProductGetByRefIdResult:Clone() )
	oClone:nproductId    := ::nproductId
	oClone:oWSProductGetSimilarCategoryResult :=  IIF(::oWSProductGetSimilarCategoryResult = NIL , NIL ,::oWSProductGetSimilarCategoryResult:Clone() )
	oClone:cdateUpdated  := ::cdateUpdated
	oClone:ntopRows      := ::ntopRows
	oClone:oWSProductGetAllFromUpdatedDateAndIdResult :=  IIF(::oWSProductGetAllFromUpdatedDateAndIdResult = NIL , NIL ,::oWSProductGetAllFromUpdatedDateAndIdResult:Clone() )
	oClone:nidSkuParent  := ::nidSkuParent
	oClone:oWSStockKeepingUnitKitListByParentResult :=  IIF(::oWSStockKeepingUnitKitListByParentResult = NIL , NIL ,::oWSStockKeepingUnitKitListByParentResult:Clone() )
	oClone:nidSku        := ::nidSku
	oClone:oWSStockKeepingUnitKitListBySkuIdResult :=  IIF(::oWSStockKeepingUnitKitListBySkuIdResult = NIL , NIL ,::oWSStockKeepingUnitKitListBySkuIdResult:Clone() )
	oClone:oWSstockKeepingUnitKit :=  IIF(::oWSstockKeepingUnitKit = NIL , NIL ,::oWSstockKeepingUnitKit:Clone() )
	oClone:oWSStockKeepingUnitKitInsertUpdateResult :=  IIF(::oWSStockKeepingUnitKitInsertUpdateResult = NIL , NIL ,::oWSStockKeepingUnitKitInsertUpdateResult:Clone() )
	oClone:nstockKeepingUnitKitId := ::nstockKeepingUnitKitId
	oClone:nidStockKeepingUnit := ::nidStockKeepingUnit
	oClone:oWSStockKeepingUnitGetAllByProductResult :=  IIF(::oWSStockKeepingUnitGetAllByProductResult = NIL , NIL ,::oWSStockKeepingUnitGetAllByProductResult:Clone() )
	oClone:cEAN13        := ::cEAN13
	oClone:oWSStockKeepingUnitGetByEanResult :=  IIF(::oWSStockKeepingUnitGetByEanResult = NIL , NIL ,::oWSStockKeepingUnitGetByEanResult:Clone() )
	oClone:nidService    := ::nidService
	oClone:oWSServiceGetResult :=  IIF(::oWSServiceGetResult = NIL , NIL ,::oWSServiceGetResult:Clone() )
	oClone:nidServicePrice := ::nidServicePrice
	oClone:oWSServicePriceGetResult :=  IIF(::oWSServicePriceGetResult = NIL , NIL ,::oWSServicePriceGetResult:Clone() )
	oClone:oWSServicePriceListResult :=  IIF(::oWSServicePriceListResult = NIL , NIL ,::oWSServicePriceListResult:Clone() )
	oClone:oWSservice    :=  IIF(::oWSservice = NIL , NIL ,::oWSservice:Clone() )
	oClone:oWSServiceInsertUpdateResult :=  IIF(::oWSServiceInsertUpdateResult = NIL , NIL ,::oWSServiceInsertUpdateResult:Clone() )
	oClone:nserviceId    := ::nserviceId
	oClone:oWSservicePrice :=  IIF(::oWSservicePrice = NIL , NIL ,::oWSservicePrice:Clone() )
	oClone:oWSServicePriceInsertUpdateResult :=  IIF(::oWSServicePriceInsertUpdateResult = NIL , NIL ,::oWSServicePriceInsertUpdateResult:Clone() )
	oClone:nservicePriceId := ::nservicePriceId
	oClone:nidStockKeepingUnitService := ::nidStockKeepingUnitService
	oClone:oWSStockKeepingUnitServiceGetResult :=  IIF(::oWSStockKeepingUnitServiceGetResult = NIL , NIL ,::oWSStockKeepingUnitServiceGetResult:Clone() )
	oClone:oWSStockKeepingUnitServiceListResult :=  IIF(::oWSStockKeepingUnitServiceListResult = NIL , NIL ,::oWSStockKeepingUnitServiceListResult:Clone() )
	oClone:oWSstockKeepingUnitService :=  IIF(::oWSstockKeepingUnitService = NIL , NIL ,::oWSstockKeepingUnitService:Clone() )
	oClone:oWSStockKeepingUnitServiceInsertUpdateResult :=  IIF(::oWSStockKeepingUnitServiceInsertUpdateResult = NIL , NIL ,::oWSStockKeepingUnitServiceInsertUpdateResult:Clone() )
	oClone:nstockKeepingUnitServiceId := ::nstockKeepingUnitServiceId
	oClone:nidBrand      := ::nidBrand
	oClone:oWSBrandGetResult :=  IIF(::oWSBrandGetResult = NIL , NIL ,::oWSBrandGetResult:Clone() )
	oClone:cnameBrand    := ::cnameBrand
	oClone:oWSBrandGetByNameResult :=  IIF(::oWSBrandGetByNameResult = NIL , NIL ,::oWSBrandGetByNameResult:Clone() )
	oClone:oWSbrand      :=  IIF(::oWSbrand = NIL , NIL ,::oWSbrand:Clone() )
	oClone:oWSBrandInsertUpdateResult :=  IIF(::oWSBrandInsertUpdateResult = NIL , NIL ,::oWSBrandInsertUpdateResult:Clone() )
	oClone:nidCategory   := ::nidCategory
	oClone:oWSCategoryGetResult :=  IIF(::oWSCategoryGetResult = NIL , NIL ,::oWSCategoryGetResult:Clone() )
	oClone:cnameCategory := ::cnameCategory
	oClone:oWSCategoryGetByNameResult :=  IIF(::oWSCategoryGetByNameResult = NIL , NIL ,::oWSCategoryGetByNameResult:Clone() )
	oClone:oWScategory   :=  IIF(::oWScategory = NIL , NIL ,::oWScategory:Clone() )
	oClone:oWSCategoryInsertUpdateResult :=  IIF(::oWSCategoryInsertUpdateResult = NIL , NIL ,::oWSCategoryInsertUpdateResult:Clone() )
	oClone:nstockKeepingUnitIdFrom := ::nstockKeepingUnitIdFrom
	oClone:nstockKeepingUnitIdTo := ::nstockKeepingUnitIdTo
	oClone:curlImage     := ::curlImage
	oClone:cimageName    := ::cimageName
	oClone:nstockKeepingUnitId := ::nstockKeepingUnitId
	oClone:nfileId       := ::nfileId
	oClone:oWSimage      :=  IIF(::oWSimage = NIL , NIL ,::oWSimage:Clone() )
	oClone:nArchiveTypeId := ::nArchiveTypeId
	oClone:oWSImageListByStockKeepingUnitIdResult :=  IIF(::oWSImageListByStockKeepingUnitIdResult = NIL , NIL ,::oWSImageListByStockKeepingUnitIdResult:Clone() )
	oClone:nskuId        := ::nskuId
	oClone:oWSStockKeepingUnitEspecificationListBySkuIdResult :=  IIF(::oWSStockKeepingUnitEspecificationListBySkuIdResult = NIL , NIL ,::oWSStockKeepingUnitEspecificationListBySkuIdResult:Clone() )
	oClone:oWSProductEspecificationListByProductIdResult :=  IIF(::oWSProductEspecificationListByProductIdResult = NIL , NIL ,::oWSProductEspecificationListByProductIdResult:Clone() )
	oClone:oWSobjStockKeepingUnitComplementDTO :=  IIF(::oWSobjStockKeepingUnitComplementDTO = NIL , NIL ,::oWSobjStockKeepingUnitComplementDTO:Clone() )
	oClone:cfieldName    := ::cfieldName
	oClone:oWSfieldValues :=  IIF(::oWSfieldValues = NIL , NIL ,::oWSfieldValues:Clone() )
	oClone:oWSlistProductFieldName :=  IIF(::oWSlistProductFieldName = NIL , NIL ,::oWSlistProductFieldName:Clone() )
	oClone:nfieldId      := ::nfieldId
	oClone:oWSlistStockKeepingUnitEspecificationFieldId :=  IIF(::oWSlistStockKeepingUnitEspecificationFieldId = NIL , NIL ,::oWSlistStockKeepingUnitEspecificationFieldId:Clone() )
	oClone:cDescription  := ::cDescription
	oClone:oWSlistStockKeepingUnitName :=  IIF(::oWSlistStockKeepingUnitName = NIL , NIL ,::oWSlistStockKeepingUnitName:Clone() )
	oClone:ncategoryId   := ::ncategoryId
	oClone:oWSStoreListResult :=  IIF(::oWSStoreListResult = NIL , NIL ,::oWSStoreListResult:Clone() )
	oClone:nstoreId      := ::nstoreId
	oClone:oWSStoreGetResult :=  IIF(::oWSStoreGetResult = NIL , NIL ,::oWSStoreGetResult:Clone() )
	oClone:oWSgiftcard   :=  IIF(::oWSgiftcard = NIL , NIL ,::oWSgiftcard:Clone() )
	oClone:oWSGiftCardInsertUpdateResult :=  IIF(::oWSGiftCardInsertUpdateResult = NIL , NIL ,::oWSGiftCardInsertUpdateResult:Clone() )
	oClone:oWSgiftCardTransactionItem :=  IIF(::oWSgiftCardTransactionItem = NIL , NIL ,::oWSgiftCardTransactionItem:Clone() )
	oClone:lGiftCardTransactionItemInsertResult := ::lGiftCardTransactionItemInsertResult
	oClone:nidGiftList   := ::nidGiftList
	oClone:oWSGiftListGetResult :=  IIF(::oWSGiftListGetResult = NIL , NIL ,::oWSGiftListGetResult:Clone() )
	oClone:cclientEmail  := ::cclientEmail
	oClone:oWSGiftListGetByClientEmailResult :=  IIF(::oWSGiftListGetByClientEmailResult = NIL , NIL ,::oWSGiftListGetByClientEmailResult:Clone() )
	oClone:cclientCpfCnpj := ::cclientCpfCnpj
	oClone:oWSGiftListGetByClientCpfResult :=  IIF(::oWSGiftListGetByClientCpfResult = NIL , NIL ,::oWSGiftListGetByClientCpfResult:Clone() )
	oClone:ngiftListTypeId := ::ngiftListTypeId
	oClone:oWSGiftListGetTypeResult :=  IIF(::oWSGiftListGetTypeResult = NIL , NIL ,::oWSGiftListGetTypeResult:Clone() )
	oClone:ccreatedDate  := ::ccreatedDate
	oClone:oWSGiftListGetByCreatedDateResult :=  IIF(::oWSGiftListGetByCreatedDateResult = NIL , NIL ,::oWSGiftListGetByCreatedDateResult:Clone() )
	oClone:nstartingGiftListId := ::nstartingGiftListId
	oClone:oWSGiftListGetAllFromCreatedDateAndIdResult :=  IIF(::oWSGiftListGetAllFromCreatedDateAndIdResult = NIL , NIL ,::oWSGiftListGetAllFromCreatedDateAndIdResult:Clone() )
	oClone:ceventDateBegin := ::ceventDateBegin
	oClone:ceventDateEnd := ::ceventDateEnd
	oClone:oWSGiftListGetAllBetweenEventDateIntervalAndIdResult :=  IIF(::oWSGiftListGetAllBetweenEventDateIntervalAndIdResult = NIL , NIL ,::oWSGiftListGetAllBetweenEventDateIntervalAndIdResult:Clone() )
	oClone:cmodifiedDate := ::cmodifiedDate
	oClone:oWSGiftListGetByModifiedDateResult :=  IIF(::oWSGiftListGetByModifiedDateResult = NIL , NIL ,::oWSGiftListGetByModifiedDateResult:Clone() )
	oClone:oWSGiftListGetAllFromModifiedDateAndIdResult :=  IIF(::oWSGiftListGetAllFromModifiedDateAndIdResult = NIL , NIL ,::oWSGiftListGetAllFromModifiedDateAndIdResult:Clone() )
	oClone:cgifted       := ::cgifted
	oClone:oWSGiftListGetByGiftedResult :=  IIF(::oWSGiftListGetByGiftedResult = NIL , NIL ,::oWSGiftListGetByGiftedResult:Clone() )
	oClone:oWSgiftList   :=  IIF(::oWSgiftList = NIL , NIL ,::oWSgiftList:Clone() )
	oClone:oWSGiftListInsertUpdateResult :=  IIF(::oWSGiftListInsertUpdateResult = NIL , NIL ,::oWSGiftListInsertUpdateResult:Clone() )
	oClone:ngiftListId   := ::ngiftListId
	oClone:nclientId     := ::nclientId
	oClone:ceventDateSince := ::ceventDateSince
	oClone:ceventDateUntil := ::ceventDateUntil
	oClone:lisActive     := ::lisActive
	oClone:oWSGiftListV2FiltersResult :=  IIF(::oWSGiftListV2FiltersResult = NIL , NIL ,::oWSGiftListV2FiltersResult:Clone() )
	oClone:cclientName   := ::cclientName
	oClone:ceventLocation := ::ceventLocation
	oClone:ceventCity    := ::ceventCity
	oClone:ceventDate    := ::ceventDate
	oClone:oWSGiftListSearchResult :=  IIF(::oWSGiftListSearchResult = NIL , NIL ,::oWSGiftListSearchResult:Clone() )
	oClone:cclientSurname := ::cclientSurname
	oClone:oWSGiftListSearchWithSurnameResult :=  IIF(::oWSGiftListSearchWithSurnameResult = NIL , NIL ,::oWSGiftListSearchWithSurnameResult:Clone() )
	oClone:oWSgiftListMember :=  IIF(::oWSgiftListMember = NIL , NIL ,::oWSgiftListMember:Clone() )
	oClone:oWSGiftListMemberInsertUpdateResult :=  IIF(::oWSGiftListMemberInsertUpdateResult = NIL , NIL ,::oWSGiftListMemberInsertUpdateResult:Clone() )
	oClone:nGiftListMemberId := ::nGiftListMemberId
	oClone:oWSgiftListSku :=  IIF(::oWSgiftListSku = NIL , NIL ,::oWSgiftListSku:Clone() )
	oClone:oWSGiftListSkuInsertResult :=  IIF(::oWSGiftListSkuInsertResult = NIL , NIL ,::oWSGiftListSkuInsertResult:Clone() )
	oClone:oWSGiftListSkuGetResult :=  IIF(::oWSGiftListSkuGetResult = NIL , NIL ,::oWSGiftListSkuGetResult:Clone() )
	oClone:nQuantity     := ::nQuantity
	oClone:norderId      := ::norderId
	oClone:oWSskuQuantity :=  IIF(::oWSskuQuantity = NIL , NIL ,::oWSskuQuantity:Clone() )
	oClone:oWSGiftCardGetResult :=  IIF(::oWSGiftCardGetResult = NIL , NIL ,::oWSGiftCardGetResult:Clone() )
	oClone:credeptionCode := ::credeptionCode
	oClone:oWSGiftCardGetByRedeptionCodeResult :=  IIF(::oWSGiftCardGetByRedeptionCodeResult = NIL , NIL ,::oWSGiftCardGetByRedeptionCodeResult:Clone() )
	oClone:oWSerrorType  :=  IIF(::oWSerrorType = NIL , NIL ,::oWSerrorType:Clone() )
	oClone:cinstance     := ::cinstance
	oClone:cerror        := ::cerror
	oClone:cerrorDetail  := ::cerrorDetail
	oClone:lIntegrationErrorCheckInstanceExistsResult := ::lIntegrationErrorCheckInstanceExistsResult
Return oClone

// WSDL Method StockKeepingUnitInsertUpdate of Service WSService

WSMETHOD StockKeepingUnitInsertUpdate WSSEND oWSstockKeepingUnitVO WSRECEIVE oWSStockKeepingUnitInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepingUnitVO", ::oWSstockKeepingUnitVO, oWSstockKeepingUnitVO , "StockKeepingUnitDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITINSERTUPDATERESPONSE:_STOCKKEEPINGUNITINSERTUPDATERESULT","StockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitPriceUpdate of Service WSService

WSMETHOD StockKeepingUnitPriceUpdate WSSEND nstockKeepintUnitId,nprice,nlistPrice,ncostPrice WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitPriceUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepintUnitId", ::nstockKeepintUnitId, nstockKeepintUnitId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("price", ::nprice, nprice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("listPrice", ::nlistPrice, nlistPrice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("costPrice", ::ncostPrice, ncostPrice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitPriceUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitPriceUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitPriceUpdateByRefId of Service WSService

WSMETHOD StockKeepingUnitPriceUpdateByRefId WSSEND cstockKeepintUnitRefId,nprice,nlistPrice,ncostPrice WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitPriceUpdateByRefId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepintUnitRefId", ::cstockKeepintUnitRefId, cstockKeepintUnitRefId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("price", ::nprice, nprice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("listPrice", ::nlistPrice, nlistPrice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("costPrice", ::ncostPrice, ncostPrice , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitPriceUpdateByRefId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitPriceUpdateByRefId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitGet of Service WSService

WSMETHOD StockKeepingUnitGet WSSEND nid WSRECEIVE oWSStockKeepingUnitGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("id", ::nid, nid , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitGetResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITGETRESPONSE:_STOCKKEEPINGUNITGETRESULT","StockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitGetByManufacturerCode of Service WSService

WSMETHOD StockKeepingUnitGetByManufacturerCode WSSEND cmanufacturer WSRECEIVE oWSStockKeepingUnitGetByManufacturerCodeResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitGetByManufacturerCode xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("manufacturer", ::cmanufacturer, cmanufacturer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitGetByManufacturerCode>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitGetByManufacturerCode",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitGetByManufacturerCodeResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITGETBYMANUFACTURERCODERESPONSE:_STOCKKEEPINGUNITGETBYMANUFACTURERCODERESULT","ArrayOfStockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitGetByRefId of Service WSService

WSMETHOD StockKeepingUnitGetByRefId WSSEND crefId WSRECEIVE oWSStockKeepingUnitGetByRefIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitGetByRefId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("refId", ::crefId, crefId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitGetByRefId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitGetByRefId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitGetByRefIdResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITGETBYREFIDRESPONSE:_STOCKKEEPINGUNITGETBYREFIDRESULT","StockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductInsertUpdate of Service WSService

WSMETHOD ProductInsertUpdate WSSEND oWSproductVO WSRECEIVE oWSProductInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("productVO", ::oWSproductVO, oWSproductVO , "ProductDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ProductInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTINSERTUPDATERESPONSE:_PRODUCTINSERTUPDATERESULT","ProductDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductGet of Service WSService

WSMETHOD ProductGet WSSEND nidProduct WSRECEIVE oWSProductGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductGetResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTGETRESPONSE:_PRODUCTGETRESULT","ProductDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductGetByRefId of Service WSService

WSMETHOD ProductGetByRefId WSSEND crefId WSRECEIVE oWSProductGetByRefIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductGetByRefId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("refId", ::crefId, crefId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductGetByRefId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductGetByRefId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductGetByRefIdResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTGETBYREFIDRESPONSE:_PRODUCTGETBYREFIDRESULT","ProductDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductGetSimilarCategory of Service WSService

WSMETHOD ProductGetSimilarCategory WSSEND nproductId WSRECEIVE oWSProductGetSimilarCategoryResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductGetSimilarCategory xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("productId", ::nproductId, nproductId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductGetSimilarCategory>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductGetSimilarCategory",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductGetSimilarCategoryResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTGETSIMILARCATEGORYRESPONSE:_PRODUCTGETSIMILARCATEGORYRESULT","ArrayOfint",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductGetAllFromUpdatedDateAndId of Service WSService

WSMETHOD ProductGetAllFromUpdatedDateAndId WSSEND cdateUpdated,nproductid,ntopRows WSRECEIVE oWSProductGetAllFromUpdatedDateAndIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductGetAllFromUpdatedDateAndId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("dateUpdated", ::cdateUpdated, cdateUpdated , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("productid", ::nproductid, nproductid , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("topRows", ::ntopRows, ntopRows , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductGetAllFromUpdatedDateAndId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductGetAllFromUpdatedDateAndId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductGetAllFromUpdatedDateAndIdResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTGETALLFROMUPDATEDDATEANDIDRESPONSE:_PRODUCTGETALLFROMUPDATEDDATEANDIDRESULT","ArrayOfProductDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductActive of Service WSService

WSMETHOD ProductActive WSSEND nidProduct WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductActive xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductActive>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductActive",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitKitListByParent of Service WSService

WSMETHOD StockKeepingUnitKitListByParent WSSEND nidSkuParent WSRECEIVE oWSStockKeepingUnitKitListByParentResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitKitListByParent xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSkuParent", ::nidSkuParent, nidSkuParent , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitKitListByParent>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitKitListByParent",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitKitListByParentResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITKITLISTBYPARENTRESPONSE:_STOCKKEEPINGUNITKITLISTBYPARENTRESULT","ArrayOfStockKeepingUnitKitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitKitListBySkuId of Service WSService

WSMETHOD StockKeepingUnitKitListBySkuId WSSEND nidSku WSRECEIVE oWSStockKeepingUnitKitListBySkuIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitKitListBySkuId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSku", ::nidSku, nidSku , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitKitListBySkuId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitKitListBySkuId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitKitListBySkuIdResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITKITLISTBYSKUIDRESPONSE:_STOCKKEEPINGUNITKITLISTBYSKUIDRESULT","ArrayOfStockKeepingUnitKitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitKitDeleteByParent of Service WSService

WSMETHOD StockKeepingUnitKitDeleteByParent WSSEND nidSkuParent WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitKitDeleteByParent xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSkuParent", ::nidSkuParent, nidSkuParent , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitKitDeleteByParent>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitKitDeleteByParent",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitKitInsertUpdate of Service WSService

WSMETHOD StockKeepingUnitKitInsertUpdate WSSEND oWSstockKeepingUnitKit WSRECEIVE oWSStockKeepingUnitKitInsertUpdateResult,nstockKeepingUnitKitId WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitKitInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepingUnitKit", ::oWSstockKeepingUnitKit, oWSstockKeepingUnitKit , "StockKeepingUnitKitDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitKitInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitKitInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitKitInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITKITINSERTUPDATERESPONSE:_STOCKKEEPINGUNITKITINSERTUPDATERESULT","StockKeepingUnitKitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )
::nstockKeepingUnitKitId :=  WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITKITINSERTUPDATERESPONSE:_STOCKKEEPINGUNITKITID:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitActive of Service WSService

WSMETHOD StockKeepingUnitActive WSSEND nidStockKeepingUnit WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitActive xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idStockKeepingUnit", ::nidStockKeepingUnit, nidStockKeepingUnit , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitActive>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitActive",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitGetAllByProduct of Service WSService

WSMETHOD StockKeepingUnitGetAllByProduct WSSEND nidProduct WSRECEIVE oWSStockKeepingUnitGetAllByProductResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitGetAllByProduct xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitGetAllByProduct>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitGetAllByProduct",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitGetAllByProductResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITGETALLBYPRODUCTRESPONSE:_STOCKKEEPINGUNITGETALLBYPRODUCTRESULT","ArrayOfStockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitGetByEan of Service WSService

WSMETHOD StockKeepingUnitGetByEan WSSEND cEAN13 WSRECEIVE oWSStockKeepingUnitGetByEanResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitGetByEan xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("EAN13", ::cEAN13, cEAN13 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitGetByEan>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitGetByEan",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitGetByEanResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITGETBYEANRESPONSE:_STOCKKEEPINGUNITGETBYEANRESULT","StockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ServiceGet of Service WSService

WSMETHOD ServiceGet WSSEND nidService WSRECEIVE oWSServiceGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ServiceGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idService", ::nidService, nidService , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ServiceGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ServiceGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSServiceGetResult:SoapRecv( WSAdvValue( oXmlRet,"_SERVICEGETRESPONSE:_SERVICEGETRESULT","ServiceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ServicePriceGet of Service WSService

WSMETHOD ServicePriceGet WSSEND nidServicePrice WSRECEIVE oWSServicePriceGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ServicePriceGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idServicePrice", ::nidServicePrice, nidServicePrice , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ServicePriceGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ServicePriceGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSServicePriceGetResult:SoapRecv( WSAdvValue( oXmlRet,"_SERVICEPRICEGETRESPONSE:_SERVICEPRICEGETRESULT","ServicePriceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ServicePriceList of Service WSService

WSMETHOD ServicePriceList WSSEND nidService WSRECEIVE oWSServicePriceListResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ServicePriceList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idService", ::nidService, nidService , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ServicePriceList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ServicePriceList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSServicePriceListResult:SoapRecv( WSAdvValue( oXmlRet,"_SERVICEPRICELISTRESPONSE:_SERVICEPRICELISTRESULT","ArrayOfServicePriceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ServiceInsertUpdate of Service WSService

WSMETHOD ServiceInsertUpdate WSSEND oWSservice WSRECEIVE oWSServiceInsertUpdateResult,nserviceId WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ServiceInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("service", ::oWSservice, oWSservice , "ServiceDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ServiceInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ServiceInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSServiceInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_SERVICEINSERTUPDATERESPONSE:_SERVICEINSERTUPDATERESULT","ServiceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )
::nserviceId         :=  WSAdvValue( oXmlRet,"_SERVICEINSERTUPDATERESPONSE:_SERVICEID:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ServicePriceInsertUpdate of Service WSService

WSMETHOD ServicePriceInsertUpdate WSSEND oWSservicePrice WSRECEIVE oWSServicePriceInsertUpdateResult,nservicePriceId WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ServicePriceInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("servicePrice", ::oWSservicePrice, oWSservicePrice , "ServicePriceDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ServicePriceInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ServicePriceInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSServicePriceInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_SERVICEPRICEINSERTUPDATERESPONSE:_SERVICEPRICEINSERTUPDATERESULT","ServicePriceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )
::nservicePriceId    :=  WSAdvValue( oXmlRet,"_SERVICEPRICEINSERTUPDATERESPONSE:_SERVICEPRICEID:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitServiceGet of Service WSService

WSMETHOD StockKeepingUnitServiceGet WSSEND nidStockKeepingUnitService WSRECEIVE oWSStockKeepingUnitServiceGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitServiceGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idStockKeepingUnitService", ::nidStockKeepingUnitService, nidStockKeepingUnitService , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitServiceGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitServiceGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitServiceGetResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITSERVICEGETRESPONSE:_STOCKKEEPINGUNITSERVICEGETRESULT","StockKeepingUnitServiceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitServiceList of Service WSService

WSMETHOD StockKeepingUnitServiceList WSSEND nidSku WSRECEIVE oWSStockKeepingUnitServiceListResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitServiceList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSku", ::nidSku, nidSku , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitServiceList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitServiceList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitServiceListResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITSERVICELISTRESPONSE:_STOCKKEEPINGUNITSERVICELISTRESULT","ArrayOfStockKeepingUnitServiceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitServiceInsertUpdate of Service WSService

WSMETHOD StockKeepingUnitServiceInsertUpdate WSSEND oWSstockKeepingUnitService WSRECEIVE oWSStockKeepingUnitServiceInsertUpdateResult,nstockKeepingUnitServiceId WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitServiceInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepingUnitService", ::oWSstockKeepingUnitService, oWSstockKeepingUnitService , "StockKeepingUnitServiceDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitServiceInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitServiceInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitServiceInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITSERVICEINSERTUPDATERESPONSE:_STOCKKEEPINGUNITSERVICEINSERTUPDATERESULT","StockKeepingUnitServiceDTO",NIL,NIL,NIL,NIL,NIL,NIL) )
::nstockKeepingUnitServiceId :=  WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITSERVICEINSERTUPDATERESPONSE:_STOCKKEEPINGUNITSERVICEID:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BrandGet of Service WSService

WSMETHOD BrandGet WSSEND nidBrand WSRECEIVE oWSBrandGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BrandGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idBrand", ::nidBrand, nidBrand , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BrandGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/BrandGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSBrandGetResult:SoapRecv( WSAdvValue( oXmlRet,"_BRANDGETRESPONSE:_BRANDGETRESULT","BrandDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BrandGetByName of Service WSService

WSMETHOD BrandGetByName WSSEND cnameBrand WSRECEIVE oWSBrandGetByNameResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BrandGetByName xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("nameBrand", ::cnameBrand, cnameBrand , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BrandGetByName>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/BrandGetByName",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSBrandGetByNameResult:SoapRecv( WSAdvValue( oXmlRet,"_BRANDGETBYNAMERESPONSE:_BRANDGETBYNAMERESULT","BrandDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BrandInsertUpdate of Service WSService

WSMETHOD BrandInsertUpdate WSSEND oWSbrand WSRECEIVE oWSBrandInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BrandInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("brand", ::oWSbrand, oWSbrand , "BrandDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</BrandInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/BrandInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSBrandInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_BRANDINSERTUPDATERESPONSE:_BRANDINSERTUPDATERESULT","BrandDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CategoryGet of Service WSService

WSMETHOD CategoryGet WSSEND nidCategory WSRECEIVE oWSCategoryGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CategoryGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idCategory", ::nidCategory, nidCategory , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CategoryGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/CategoryGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSCategoryGetResult:SoapRecv( WSAdvValue( oXmlRet,"_CATEGORYGETRESPONSE:_CATEGORYGETRESULT","CategoryDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CategoryGetByName of Service WSService

WSMETHOD CategoryGetByName WSSEND cnameCategory WSRECEIVE oWSCategoryGetByNameResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CategoryGetByName xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("nameCategory", ::cnameCategory, cnameCategory , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CategoryGetByName>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/CategoryGetByName",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSCategoryGetByNameResult:SoapRecv( WSAdvValue( oXmlRet,"_CATEGORYGETBYNAMERESPONSE:_CATEGORYGETBYNAMERESULT","CategoryDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CategoryInsertUpdate of Service WSService

WSMETHOD CategoryInsertUpdate WSSEND oWScategory WSRECEIVE oWSCategoryInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CategoryInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("category", ::oWScategory, oWScategory , "CategoryDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</CategoryInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/CategoryInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSCategoryInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_CATEGORYINSERTUPDATERESPONSE:_CATEGORYINSERTUPDATERESULT","CategoryDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImageServiceCopyAllImagesFromSkuToSku of Service WSService

WSMETHOD ImageServiceCopyAllImagesFromSkuToSku WSSEND nstockKeepingUnitIdFrom,nstockKeepingUnitIdTo WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImageServiceCopyAllImagesFromSkuToSku xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepingUnitIdFrom", ::nstockKeepingUnitIdFrom, nstockKeepingUnitIdFrom , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("stockKeepingUnitIdTo", ::nstockKeepingUnitIdTo, nstockKeepingUnitIdTo , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImageServiceCopyAllImagesFromSkuToSku>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ImageServiceCopyAllImagesFromSkuToSku",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImageServiceInsertUpdate of Service WSService

WSMETHOD ImageServiceInsertUpdate WSSEND curlImage,cimageName,nstockKeepingUnitId,nfileId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImageServiceInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("urlImage", ::curlImage, curlImage , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("imageName", ::cimageName, cimageName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("stockKeepingUnitId", ::nstockKeepingUnitId, nstockKeepingUnitId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fileId", ::nfileId, nfileId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImageServiceInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ImageServiceInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImageInsertUpdate of Service WSService

WSMETHOD ImageInsertUpdate WSSEND oWSimage WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImageInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("image", ::oWSimage, oWSimage , "ImageDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ImageInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ImageInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImageListByStockKeepingUnitId of Service WSService

WSMETHOD ImageListByStockKeepingUnitId WSSEND nStockKeepingUnitId,nArchiveTypeId WSRECEIVE oWSImageListByStockKeepingUnitIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImageListByStockKeepingUnitId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, nStockKeepingUnitId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ArchiveTypeId", ::nArchiveTypeId, nArchiveTypeId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImageListByStockKeepingUnitId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ImageListByStockKeepingUnitId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSImageListByStockKeepingUnitIdResult:SoapRecv( WSAdvValue( oXmlRet,"_IMAGELISTBYSTOCKKEEPINGUNITIDRESPONSE:_IMAGELISTBYSTOCKKEEPINGUNITIDRESULT","ArrayOfImageDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitImageRemove of Service WSService

WSMETHOD StockKeepingUnitImageRemove WSSEND nstockKeepingUnitId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitImageRemove xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("stockKeepingUnitId", ::nstockKeepingUnitId, nstockKeepingUnitId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitImageRemove>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitImageRemove",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitImageRemoveByName of Service WSService

WSMETHOD StockKeepingUnitImageRemoveByName WSSEND cimageName WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitImageRemoveByName xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("imageName", ::cimageName, cimageName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitImageRemoveByName>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitImageRemoveByName",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitEspecificationListBySkuId of Service WSService

WSMETHOD StockKeepingUnitEspecificationListBySkuId WSSEND nskuId WSRECEIVE oWSStockKeepingUnitEspecificationListBySkuIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitEspecificationListBySkuId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("skuId", ::nskuId, nskuId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StockKeepingUnitEspecificationListBySkuId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitEspecificationListBySkuId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStockKeepingUnitEspecificationListBySkuIdResult:SoapRecv( WSAdvValue( oXmlRet,"_STOCKKEEPINGUNITESPECIFICATIONLISTBYSKUIDRESPONSE:_STOCKKEEPINGUNITESPECIFICATIONLISTBYSKUIDRESULT","ArrayOfFieldDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationListByProductId of Service WSService

WSMETHOD ProductEspecificationListByProductId WSSEND nproductId WSRECEIVE oWSProductEspecificationListByProductIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationListByProductId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("productId", ::nproductId, nproductId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductEspecificationListByProductId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationListByProductId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSProductEspecificationListByProductIdResult:SoapRecv( WSAdvValue( oXmlRet,"_PRODUCTESPECIFICATIONLISTBYPRODUCTIDRESPONSE:_PRODUCTESPECIFICATIONLISTBYPRODUCTIDRESULT","ArrayOfFieldDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitComplementInsertUpdate of Service WSService

WSMETHOD StockKeepingUnitComplementInsertUpdate WSSEND oWSobjStockKeepingUnitComplementDTO WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitComplementInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("objStockKeepingUnitComplementDTO", ::oWSobjStockKeepingUnitComplementDTO, oWSobjStockKeepingUnitComplementDTO , "StockKeepingUnitComplementDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitComplementInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitComplementInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationInsert of Service WSService

WSMETHOD ProductEspecificationInsert WSSEND nidProduct,cfieldName,oWSfieldValues WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationInsert xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldName", ::cfieldName, cfieldName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ProductEspecificationInsert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationInsert",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationInsertByList of Service WSService

WSMETHOD ProductEspecificationInsertByList WSSEND oWSlistProductFieldName WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationInsertByList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("listProductFieldName", ::oWSlistProductFieldName, oWSlistProductFieldName , "ArrayOfProductFieldNameDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ProductEspecificationInsertByList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationInsertByList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationInsertByFieldId of Service WSService

WSMETHOD ProductEspecificationInsertByFieldId WSSEND nidProduct,nfieldId,oWSfieldValues WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationInsertByFieldId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldId", ::nfieldId, nfieldId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ProductEspecificationInsertByFieldId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationInsertByFieldId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationInsertByListFieldIds of Service WSService

WSMETHOD ProductEspecificationInsertByListFieldIds WSSEND oWSlistStockKeepingUnitEspecificationFieldId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationInsertByListFieldIds xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("listStockKeepingUnitEspecificationFieldId", ::oWSlistStockKeepingUnitEspecificationFieldId, oWSlistStockKeepingUnitEspecificationFieldId , "ArrayOfProductFieldIdDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</ProductEspecificationInsertByListFieldIds>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationInsertByListFieldIds",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductEspecificationTextInsertByFieldId of Service WSService

WSMETHOD ProductEspecificationTextInsertByFieldId WSSEND nidProduct,nfieldId,cDescription WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductEspecificationTextInsertByFieldId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProduct", ::nidProduct, nidProduct , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldId", ::nfieldId, nfieldId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Description", ::cDescription, cDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductEspecificationTextInsertByFieldId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductEspecificationTextInsertByFieldId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitEspecificationInsertByList of Service WSService

WSMETHOD StockKeepingUnitEspecificationInsertByList WSSEND oWSlistStockKeepingUnitName WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitEspecificationInsertByList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("listStockKeepingUnitName", ::oWSlistStockKeepingUnitName, oWSlistStockKeepingUnitName , "ArrayOfStockKeepingUnitFieldNameDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitEspecificationInsertByList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitEspecificationInsertByList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitEspecificationInsert of Service WSService

WSMETHOD StockKeepingUnitEspecificationInsert WSSEND nidSku,cfieldName,oWSfieldValues WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitEspecificationInsert xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSku", ::nidSku, nidSku , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldName", ::cfieldName, cfieldName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitEspecificationInsert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitEspecificationInsert",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProductSetSimilarCategory of Service WSService

WSMETHOD ProductSetSimilarCategory WSSEND nproductId,ncategoryId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProductSetSimilarCategory xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("productId", ::nproductId, nproductId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("categoryId", ::ncategoryId, ncategoryId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ProductSetSimilarCategory>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/ProductSetSimilarCategory",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StoreList of Service WSService

WSMETHOD StoreList WSSEND NULLPARAM WSRECEIVE oWSStoreListResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StoreList xmlns="http://tempuri.org/">'
cSoap += "</StoreList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StoreList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStoreListResult:SoapRecv( WSAdvValue( oXmlRet,"_STORELISTRESPONSE:_STORELISTRESULT","ArrayOfStoreDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StoreGet of Service WSService

WSMETHOD StoreGet WSSEND nstoreId WSRECEIVE oWSStoreGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StoreGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("storeId", ::nstoreId, nstoreId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StoreGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StoreGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSStoreGetResult:SoapRecv( WSAdvValue( oXmlRet,"_STOREGETRESPONSE:_STOREGETRESULT","StoreDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StockKeepingUnitEspecificationInsertByFieldId of Service WSService

WSMETHOD StockKeepingUnitEspecificationInsertByFieldId WSSEND nidSku,nfieldId,oWSfieldValues WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StockKeepingUnitEspecificationInsertByFieldId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idSku", ::nidSku, nidSku , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldId", ::nfieldId, nfieldId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</StockKeepingUnitEspecificationInsertByFieldId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/StockKeepingUnitEspecificationInsertByFieldId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftCardInsertUpdate of Service WSService

WSMETHOD GiftCardInsertUpdate WSSEND oWSgiftcard WSRECEIVE oWSGiftCardInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftCardInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftcard", ::oWSgiftcard, oWSgiftcard , "GiftCardDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftCardInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftCardInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftCardInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTCARDINSERTUPDATERESPONSE:_GIFTCARDINSERTUPDATERESULT","GiftCardDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftCardTransactionItemInsert of Service WSService

WSMETHOD GiftCardTransactionItemInsert WSSEND oWSgiftCardTransactionItem WSRECEIVE lGiftCardTransactionItemInsertResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftCardTransactionItemInsert xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftCardTransactionItem", ::oWSgiftCardTransactionItem, oWSgiftCardTransactionItem , "GiftCardTransactionItemDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftCardTransactionItemInsert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftCardTransactionItemInsert",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::lGiftCardTransactionItemInsertResult :=  WSAdvValue( oXmlRet,"_GIFTCARDTRANSACTIONITEMINSERTRESPONSE:_GIFTCARDTRANSACTIONITEMINSERTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGet of Service WSService

WSMETHOD GiftListGet WSSEND nidGiftList WSRECEIVE oWSGiftListGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idGiftList", ::nidGiftList, nidGiftList , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETRESPONSE:_GIFTLISTGETRESULT","GiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetByClientEmail of Service WSService

WSMETHOD GiftListGetByClientEmail WSSEND cclientEmail WSRECEIVE oWSGiftListGetByClientEmailResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetByClientEmail xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("clientEmail", ::cclientEmail, cclientEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetByClientEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetByClientEmail",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetByClientEmailResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETBYCLIENTEMAILRESPONSE:_GIFTLISTGETBYCLIENTEMAILRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetByClientCpf of Service WSService

WSMETHOD GiftListGetByClientCpf WSSEND cclientCpfCnpj WSRECEIVE oWSGiftListGetByClientCpfResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetByClientCpf xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("clientCpfCnpj", ::cclientCpfCnpj, cclientCpfCnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetByClientCpf>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetByClientCpf",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetByClientCpfResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETBYCLIENTCPFRESPONSE:_GIFTLISTGETBYCLIENTCPFRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetType of Service WSService

WSMETHOD GiftListGetType WSSEND ngiftListTypeId WSRECEIVE oWSGiftListGetTypeResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetType xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListTypeId", ::ngiftListTypeId, ngiftListTypeId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetType>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetType",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetTypeResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETTYPERESPONSE:_GIFTLISTGETTYPERESULT","GiftListTypeDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetByCreatedDate of Service WSService

WSMETHOD GiftListGetByCreatedDate WSSEND ccreatedDate WSRECEIVE oWSGiftListGetByCreatedDateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetByCreatedDate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("createdDate", ::ccreatedDate, ccreatedDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetByCreatedDate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetByCreatedDate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetByCreatedDateResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETBYCREATEDDATERESPONSE:_GIFTLISTGETBYCREATEDDATERESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetAllFromCreatedDateAndId of Service WSService

WSMETHOD GiftListGetAllFromCreatedDateAndId WSSEND ccreatedDate,nstartingGiftListId,ntopRows WSRECEIVE oWSGiftListGetAllFromCreatedDateAndIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetAllFromCreatedDateAndId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("createdDate", ::ccreatedDate, ccreatedDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("startingGiftListId", ::nstartingGiftListId, nstartingGiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("topRows", ::ntopRows, ntopRows , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetAllFromCreatedDateAndId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetAllFromCreatedDateAndId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetAllFromCreatedDateAndIdResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETALLFROMCREATEDDATEANDIDRESPONSE:_GIFTLISTGETALLFROMCREATEDDATEANDIDRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetAllBetweenEventDateIntervalAndId of Service WSService

WSMETHOD GiftListGetAllBetweenEventDateIntervalAndId WSSEND ceventDateBegin,ceventDateEnd,nstartingGiftListId,ntopRows WSRECEIVE oWSGiftListGetAllBetweenEventDateIntervalAndIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetAllBetweenEventDateIntervalAndId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("eventDateBegin", ::ceventDateBegin, ceventDateBegin , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventDateEnd", ::ceventDateEnd, ceventDateEnd , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("startingGiftListId", ::nstartingGiftListId, nstartingGiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("topRows", ::ntopRows, ntopRows , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetAllBetweenEventDateIntervalAndId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetAllBetweenEventDateIntervalAndId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetAllBetweenEventDateIntervalAndIdResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETALLBETWEENEVENTDATEINTERVALANDIDRESPONSE:_GIFTLISTGETALLBETWEENEVENTDATEINTERVALANDIDRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetByModifiedDate of Service WSService

WSMETHOD GiftListGetByModifiedDate WSSEND cmodifiedDate WSRECEIVE oWSGiftListGetByModifiedDateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetByModifiedDate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("modifiedDate", ::cmodifiedDate, cmodifiedDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetByModifiedDate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetByModifiedDate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetByModifiedDateResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETBYMODIFIEDDATERESPONSE:_GIFTLISTGETBYMODIFIEDDATERESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetAllFromModifiedDateAndId of Service WSService

WSMETHOD GiftListGetAllFromModifiedDateAndId WSSEND cmodifiedDate,nstartingGiftListId,ntopRows WSRECEIVE oWSGiftListGetAllFromModifiedDateAndIdResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetAllFromModifiedDateAndId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("modifiedDate", ::cmodifiedDate, cmodifiedDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("startingGiftListId", ::nstartingGiftListId, nstartingGiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("topRows", ::ntopRows, ntopRows , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetAllFromModifiedDateAndId>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetAllFromModifiedDateAndId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetAllFromModifiedDateAndIdResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETALLFROMMODIFIEDDATEANDIDRESPONSE:_GIFTLISTGETALLFROMMODIFIEDDATEANDIDRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListGetByGifted of Service WSService

WSMETHOD GiftListGetByGifted WSSEND cgifted WSRECEIVE oWSGiftListGetByGiftedResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListGetByGifted xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("gifted", ::cgifted, cgifted , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListGetByGifted>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListGetByGifted",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListGetByGiftedResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTGETBYGIFTEDRESPONSE:_GIFTLISTGETBYGIFTEDRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListInsertUpdate of Service WSService

WSMETHOD GiftListInsertUpdate WSSEND oWSgiftList WSRECEIVE oWSGiftListInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftList", ::oWSgiftList, oWSgiftList , "GiftListDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftListInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTINSERTUPDATERESPONSE:_GIFTLISTINSERTUPDATERESULT","GiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListV2Filters of Service WSService

WSMETHOD GiftListV2Filters WSSEND ngiftListTypeId,ngiftListId,nclientId,ceventDateSince,ceventDateUntil,lisActive WSRECEIVE oWSGiftListV2FiltersResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListV2Filters xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListTypeId", ::ngiftListTypeId, ngiftListTypeId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("giftListId", ::ngiftListId, ngiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("clientId", ::nclientId, nclientId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventDateSince", ::ceventDateSince, ceventDateSince , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventDateUntil", ::ceventDateUntil, ceventDateUntil , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("isActive", ::lisActive, lisActive , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListV2Filters>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListV2Filters",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListV2FiltersResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTV2FILTERSRESPONSE:_GIFTLISTV2FILTERSRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSearch of Service WSService

WSMETHOD GiftListSearch WSSEND cclientName,ceventLocation,ceventCity,ceventDate WSRECEIVE oWSGiftListSearchResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSearch xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("clientName", ::cclientName, cclientName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventLocation", ::ceventLocation, ceventLocation , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventCity", ::ceventCity, ceventCity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventDate", ::ceventDate, ceventDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListSearch>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSearch",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListSearchResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTSEARCHRESPONSE:_GIFTLISTSEARCHRESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSearchWithSurname of Service WSService

WSMETHOD GiftListSearchWithSurname WSSEND cclientName,cclientSurname,ceventLocation,ceventCity,ceventDate WSRECEIVE oWSGiftListSearchWithSurnameResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSearchWithSurname xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("clientName", ::cclientName, cclientName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("clientSurname", ::cclientSurname, cclientSurname , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventLocation", ::ceventLocation, ceventLocation , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventCity", ::ceventCity, ceventCity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("eventDate", ::ceventDate, ceventDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListSearchWithSurname>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSearchWithSurname",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListSearchWithSurnameResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTSEARCHWITHSURNAMERESPONSE:_GIFTLISTSEARCHWITHSURNAMERESULT","ArrayOfGiftListDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListMemberInsertUpdate of Service WSService

WSMETHOD GiftListMemberInsertUpdate WSSEND oWSgiftListMember WSRECEIVE oWSGiftListMemberInsertUpdateResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListMemberInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListMember", ::oWSgiftListMember, oWSgiftListMember , "ArrayOfGiftListMemberDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftListMemberInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListMemberInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListMemberInsertUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTMEMBERINSERTUPDATERESPONSE:_GIFTLISTMEMBERINSERTUPDATERESULT","ArrayOfGiftListMemberDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListMemberDelete of Service WSService

WSMETHOD GiftListMemberDelete WSSEND nGiftListMemberId,nGiftListId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListMemberDelete xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("GiftListMemberId", ::nGiftListMemberId, nGiftListMemberId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("GiftListId", ::nGiftListId, nGiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListMemberDelete>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListMemberDelete",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSkuInsert of Service WSService

WSMETHOD GiftListSkuInsert WSSEND oWSgiftListSku WSRECEIVE oWSGiftListSkuInsertResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSkuInsert xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListSku", ::oWSgiftListSku, oWSgiftListSku , "GiftListStockKeepingUnitDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftListSkuInsert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSkuInsert",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListSkuInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTSKUINSERTRESPONSE:_GIFTLISTSKUINSERTRESULT","GiftListStockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSkuGet of Service WSService

WSMETHOD GiftListSkuGet WSSEND nidGiftList WSRECEIVE oWSGiftListSkuGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSkuGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idGiftList", ::nidGiftList, nidGiftList , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListSkuGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSkuGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftListSkuGetResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTLISTSKUGETRESPONSE:_GIFTLISTSKUGETRESULT","ArrayOfGiftListStockKeepingUnitDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSkuSetPurchased of Service WSService

WSMETHOD GiftListSkuSetPurchased WSSEND ngiftListId,nskuId,nQuantity,norderId WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSkuSetPurchased xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListId", ::ngiftListId, ngiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("skuId", ::nskuId, nskuId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Quantity", ::nQuantity, nQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("orderId", ::norderId, norderId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListSkuSetPurchased>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSkuSetPurchased",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSkuDeleteByList of Service WSService

WSMETHOD GiftListSkuDeleteByList WSSEND ngiftListId,oWSskuQuantity WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSkuDeleteByList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListId", ::ngiftListId, ngiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("skuQuantity", ::oWSskuQuantity, oWSskuQuantity , "ArrayOfStockKeepingUnitQuantityDTO", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GiftListSkuDeleteByList>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSkuDeleteByList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftListSkuDelete of Service WSService

WSMETHOD GiftListSkuDelete WSSEND ngiftListId,nskuId,nQuantity WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftListSkuDelete xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("giftListId", ::ngiftListId, ngiftListId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("skuId", ::nskuId, nskuId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Quantity", ::nQuantity, nQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftListSkuDelete>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftListSkuDelete",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftCardGet of Service WSService

WSMETHOD GiftCardGet WSSEND nId WSRECEIVE oWSGiftCardGetResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftCardGet xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Id", ::nId, nId , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftCardGet>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftCardGet",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftCardGetResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTCARDGETRESPONSE:_GIFTCARDGETRESULT","GiftCardDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GiftCardGetByRedeptionCode of Service WSService

WSMETHOD GiftCardGetByRedeptionCode WSSEND credeptionCode WSRECEIVE oWSGiftCardGetByRedeptionCodeResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GiftCardGetByRedeptionCode xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("redeptionCode", ::credeptionCode, credeptionCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GiftCardGetByRedeptionCode>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GiftCardGetByRedeptionCode",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::oWSGiftCardGetByRedeptionCodeResult:SoapRecv( WSAdvValue( oXmlRet,"_GIFTCARDGETBYREDEPTIONCODERESPONSE:_GIFTCARDGETBYREDEPTIONCODERESULT","GiftCardDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegrationLogErrorInsertUpdate of Service WSService

WSMETHOD IntegrationLogErrorInsertUpdate WSSEND oWSerrorType,cinstance,cerror,cerrorDetail WSRECEIVE NULLPARAM WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegrationLogErrorInsertUpdate xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("errorType", ::oWSerrorType, oWSerrorType , "ErrorType", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += WSSoapValue("instance", ::cinstance, cinstance , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("error", ::cerror, cerror , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("errorDetail", ::cerrorDetail, cerrorDetail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IntegrationLogErrorInsertUpdate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/IntegrationLogErrorInsertUpdate",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegrationErrorCheckInstanceExists of Service WSService

WSMETHOD IntegrationErrorCheckInstanceExists WSSEND oWSerrorType,cinstance WSRECEIVE lIntegrationErrorCheckInstanceExistsResult WSCLIENT WSVTex
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegrationErrorCheckInstanceExists xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("errorType", ::oWSerrorType, oWSerrorType , "ErrorType", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += WSSoapValue("instance", ::cinstance, cinstance , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IntegrationErrorCheckInstanceExists>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/IntegrationErrorCheckInstanceExists",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://webservice-danacosmeticos.vtexcommerce.com.br/AdminWebService/Service.svc")

::Init()
::lIntegrationErrorCheckInstanceExistsResult :=  WSAdvValue( oXmlRet,"_INTEGRATIONERRORCHECKINSTANCEEXISTSRESPONSE:_INTEGRATIONERRORCHECKINSTANCEEXISTSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure StockKeepingUnitDTO

WSSTRUCT Service_StockKeepingUnitDTO
	WSDATA   nCommercialConditionId    AS int OPTIONAL
	WSDATA   nCostPrice                AS decimal OPTIONAL
	WSDATA   nCubicWeight              AS decimal OPTIONAL
	WSDATA   cDateUpdated              AS dateTime OPTIONAL
	WSDATA   cEstimatedDateArrival     AS dateTime OPTIONAL
	WSDATA   nHeight                   AS decimal OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   cInternalNote             AS string OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   lIsAvaiable               AS boolean OPTIONAL
	WSDATA   lIsKit                    AS boolean OPTIONAL
	WSDATA   nLength                   AS decimal OPTIONAL
	WSDATA   nListPrice                AS decimal OPTIONAL
	WSDATA   cManufacturerCode         AS string OPTIONAL
	WSDATA   cMeasurementUnit          AS string OPTIONAL
	WSDATA   nModalId                  AS int OPTIONAL
	WSDATA   cModalType                AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nPrice                    AS decimal OPTIONAL
	WSDATA   nProductId                AS int OPTIONAL
	WSDATA   cProductName              AS string OPTIONAL
	WSDATA   nRealHeight               AS decimal OPTIONAL
	WSDATA   nRealLength               AS decimal OPTIONAL
	WSDATA   nRealWeightKg             AS decimal OPTIONAL
	WSDATA   nRealWidth                AS decimal OPTIONAL
	WSDATA   cRefId                    AS string OPTIONAL
	WSDATA   nRewardValue              AS decimal OPTIONAL
	WSDATA   oWSStockKeepingUnitEans   AS Service_ArrayOfStockKeepingUnitEanDTO OPTIONAL
	WSDATA   nUnitMultiplier           AS decimal OPTIONAL
	WSDATA   lVenderSeparadamente      AS boolean OPTIONAL
	WSDATA   nWeightKg                 AS decimal OPTIONAL
	WSDATA   nWidth                    AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitDTO
	Local oClone := Service_StockKeepingUnitDTO():NEW()
	oClone:nCommercialConditionId := ::nCommercialConditionId
	oClone:nCostPrice           := ::nCostPrice
	oClone:nCubicWeight         := ::nCubicWeight
	oClone:cDateUpdated         := ::cDateUpdated
	oClone:cEstimatedDateArrival := ::cEstimatedDateArrival
	oClone:nHeight              := ::nHeight
	oClone:nId                  := ::nId
	oClone:cInternalNote        := ::cInternalNote
	oClone:lIsActive            := ::lIsActive
	oClone:lIsAvaiable          := ::lIsAvaiable
	oClone:lIsKit               := ::lIsKit
	oClone:nLength              := ::nLength
	oClone:nListPrice           := ::nListPrice
	oClone:cManufacturerCode    := ::cManufacturerCode
	oClone:cMeasurementUnit     := ::cMeasurementUnit
	oClone:nModalId             := ::nModalId
	oClone:cModalType           := ::cModalType
	oClone:cName                := ::cName
	oClone:nPrice               := ::nPrice
	oClone:nProductId           := ::nProductId
	oClone:cProductName         := ::cProductName
	oClone:nRealHeight          := ::nRealHeight
	oClone:nRealLength          := ::nRealLength
	oClone:nRealWeightKg        := ::nRealWeightKg
	oClone:nRealWidth           := ::nRealWidth
	oClone:cRefId               := ::cRefId
	oClone:nRewardValue         := ::nRewardValue
	oClone:oWSStockKeepingUnitEans := IIF(::oWSStockKeepingUnitEans = NIL , NIL , ::oWSStockKeepingUnitEans:Clone() )
	oClone:nUnitMultiplier      := ::nUnitMultiplier
	oClone:lVenderSeparadamente := ::lVenderSeparadamente
	oClone:nWeightKg            := ::nWeightKg
	oClone:nWidth               := ::nWidth
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitDTO
	Local cSoap := ""
	cSoap += WSSoapValue("CommercialConditionId", ::nCommercialConditionId, ::nCommercialConditionId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("CostPrice", ::nCostPrice, ::nCostPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("CubicWeight", ::nCubicWeight, ::nCubicWeight , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DateUpdated", ::cDateUpdated, ::cDateUpdated , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("EstimatedDateArrival", ::cEstimatedDateArrival, ::cEstimatedDateArrival , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Height", ::nHeight, ::nHeight , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("InternalNote", ::cInternalNote, ::cInternalNote , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsAvaiable", ::lIsAvaiable, ::lIsAvaiable , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsKit", ::lIsKit, ::lIsKit , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Length", ::nLength, ::nLength , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ListPrice", ::nListPrice, ::nListPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ManufacturerCode", ::cManufacturerCode, ::cManufacturerCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("MeasurementUnit", ::cMeasurementUnit, ::cMeasurementUnit , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ModalId", ::nModalId, ::nModalId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ModalType", ::cModalType, ::cModalType , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Price", ::nPrice, ::nPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ProductId", ::nProductId, ::nProductId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ProductName", ::cProductName, ::cProductName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RealHeight", ::nRealHeight, ::nRealHeight , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RealLength", ::nRealLength, ::nRealLength , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RealWeightKg", ::nRealWeightKg, ::nRealWeightKg , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RealWidth", ::nRealWidth, ::nRealWidth , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RefId", ::cRefId, ::cRefId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RewardValue", ::nRewardValue, ::nRewardValue , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitEans", ::oWSStockKeepingUnitEans, ::oWSStockKeepingUnitEans , "ArrayOfStockKeepingUnitEanDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("UnitMultiplier", ::nUnitMultiplier, ::nUnitMultiplier , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("VenderSeparadamente", ::lVenderSeparadamente, ::lVenderSeparadamente , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("WeightKg", ::nWeightKg, ::nWeightKg , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Width", ::nWidth, ::nWidth , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StockKeepingUnitDTO
	Local oNode28
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCommercialConditionId :=  WSAdvValue( oResponse,"_COMMERCIALCONDITIONID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nCostPrice         :=  WSAdvValue( oResponse,"_COSTPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nCubicWeight       :=  WSAdvValue( oResponse,"_CUBICWEIGHT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDateUpdated       :=  WSAdvValue( oResponse,"_DATEUPDATED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstimatedDateArrival :=  WSAdvValue( oResponse,"_ESTIMATEDDATEARRIVAL","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::nHeight            :=  WSAdvValue( oResponse,"_HEIGHT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cInternalNote      :=  WSAdvValue( oResponse,"_INTERNALNOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsAvaiable        :=  WSAdvValue( oResponse,"_ISAVAIABLE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsKit             :=  WSAdvValue( oResponse,"_ISKIT","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nLength            :=  WSAdvValue( oResponse,"_LENGTH","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nListPrice         :=  WSAdvValue( oResponse,"_LISTPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cManufacturerCode  :=  WSAdvValue( oResponse,"_MANUFACTURERCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMeasurementUnit   :=  WSAdvValue( oResponse,"_MEASUREMENTUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nModalId           :=  WSAdvValue( oResponse,"_MODALID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cModalType         :=  WSAdvValue( oResponse,"_MODALTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPrice             :=  WSAdvValue( oResponse,"_PRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nProductId         :=  WSAdvValue( oResponse,"_PRODUCTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cProductName       :=  WSAdvValue( oResponse,"_PRODUCTNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nRealHeight        :=  WSAdvValue( oResponse,"_REALHEIGHT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nRealLength        :=  WSAdvValue( oResponse,"_REALLENGTH","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nRealWeightKg      :=  WSAdvValue( oResponse,"_REALWEIGHTKG","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nRealWidth         :=  WSAdvValue( oResponse,"_REALWIDTH","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cRefId             :=  WSAdvValue( oResponse,"_REFID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nRewardValue       :=  WSAdvValue( oResponse,"_REWARDVALUE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode28 :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITEANS","ArrayOfStockKeepingUnitEanDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode28 != NIL
		::oWSStockKeepingUnitEans := Service_ArrayOfStockKeepingUnitEanDTO():New()
		::oWSStockKeepingUnitEans:SoapRecv(oNode28)
	EndIf
	::nUnitMultiplier    :=  WSAdvValue( oResponse,"_UNITMULTIPLIER","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lVenderSeparadamente :=  WSAdvValue( oResponse,"_VENDERSEPARADAMENTE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nWeightKg          :=  WSAdvValue( oResponse,"_WEIGHTKG","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nWidth             :=  WSAdvValue( oResponse,"_WIDTH","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfStockKeepingUnitDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitDTO
	WSDATA   oWSStockKeepingUnitDTO    AS Service_StockKeepingUnitDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitDTO
	::oWSStockKeepingUnitDTO := {} // Array Of  Service_STOCKKEEPINGUNITDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitDTO
	Local oClone := Service_ArrayOfStockKeepingUnitDTO():NEW()
	oClone:oWSStockKeepingUnitDTO := NIL
	If ::oWSStockKeepingUnitDTO <> NIL 
		oClone:oWSStockKeepingUnitDTO := {}
		aEval( ::oWSStockKeepingUnitDTO , { |x| aadd( oClone:oWSStockKeepingUnitDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfStockKeepingUnitDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITDTO","StockKeepingUnitDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStockKeepingUnitDTO , Service_StockKeepingUnitDTO():New() )
			::oWSStockKeepingUnitDTO[len(::oWSStockKeepingUnitDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ProductDTO

WSSTRUCT Service_ProductDTO
	WSDATA   cAdWordsRemarketingCode   AS string OPTIONAL
	WSDATA   nBrandId                  AS int OPTIONAL
	WSDATA   nCategoryId               AS int OPTIONAL
	WSDATA   nDepartmentId             AS int OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   cDescriptionShort         AS string OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   lIsVisible                AS boolean OPTIONAL
	WSDATA   cKeyWords                 AS string OPTIONAL
	WSDATA   cLinkId                   AS string OPTIONAL
	WSDATA   oWSListStoreId            AS Service_ArrayOfint OPTIONAL
	WSDATA   cLomadeeCampaignCode      AS string OPTIONAL
	WSDATA   cMetaTagDescription       AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   cRefId                    AS string OPTIONAL
	WSDATA   cReleaseDate              AS dateTime OPTIONAL
	WSDATA   nScore                    AS int OPTIONAL
	WSDATA   lShowWithoutStock         AS boolean OPTIONAL
	WSDATA   nSupplierId               AS int OPTIONAL
	WSDATA   cTaxCode                  AS string OPTIONAL
	WSDATA   cTitle                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ProductDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ProductDTO
Return

WSMETHOD CLONE WSCLIENT Service_ProductDTO
	Local oClone := Service_ProductDTO():NEW()
	oClone:cAdWordsRemarketingCode := ::cAdWordsRemarketingCode
	oClone:nBrandId             := ::nBrandId
	oClone:nCategoryId          := ::nCategoryId
	oClone:nDepartmentId        := ::nDepartmentId
	oClone:cDescription         := ::cDescription
	oClone:cDescriptionShort    := ::cDescriptionShort
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:lIsVisible           := ::lIsVisible
	oClone:cKeyWords            := ::cKeyWords
	oClone:cLinkId              := ::cLinkId
	oClone:oWSListStoreId       := IIF(::oWSListStoreId = NIL , NIL , ::oWSListStoreId:Clone() )
	oClone:cLomadeeCampaignCode := ::cLomadeeCampaignCode
	oClone:cMetaTagDescription  := ::cMetaTagDescription
	oClone:cName                := ::cName
	oClone:cRefId               := ::cRefId
	oClone:cReleaseDate         := ::cReleaseDate
	oClone:nScore               := ::nScore
	oClone:lShowWithoutStock    := ::lShowWithoutStock
	oClone:nSupplierId          := ::nSupplierId
	oClone:cTaxCode             := ::cTaxCode
	oClone:cTitle               := ::cTitle
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ProductDTO
	Local cSoap := ""
	cSoap += WSSoapValue("AdWordsRemarketingCode", ::cAdWordsRemarketingCode, ::cAdWordsRemarketingCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("BrandId", ::nBrandId, ::nBrandId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("CategoryId", ::nCategoryId, ::nCategoryId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DepartmentId", ::nDepartmentId, ::nDepartmentId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DescriptionShort", ::cDescriptionShort, ::cDescriptionShort , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsVisible", ::lIsVisible, ::lIsVisible , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("KeyWords", ::cKeyWords, ::cKeyWords , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("LinkId", ::cLinkId, ::cLinkId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ListStoreId", ::oWSListStoreId, ::oWSListStoreId , "ArrayOfint", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("LomadeeCampaignCode", ::cLomadeeCampaignCode, ::cLomadeeCampaignCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("MetaTagDescription", ::cMetaTagDescription, ::cMetaTagDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RefId", ::cRefId, ::cRefId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ReleaseDate", ::cReleaseDate, ::cReleaseDate , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Score", ::nScore, ::nScore , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ShowWithoutStock", ::lShowWithoutStock, ::lShowWithoutStock , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("SupplierId", ::nSupplierId, ::nSupplierId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("TaxCode", ::cTaxCode, ::cTaxCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Title", ::cTitle, ::cTitle , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ProductDTO
	Local oNode12
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAdWordsRemarketingCode :=  WSAdvValue( oResponse,"_ADWORDSREMARKETINGCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nBrandId           :=  WSAdvValue( oResponse,"_BRANDID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nCategoryId        :=  WSAdvValue( oResponse,"_CATEGORYID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDepartmentId      :=  WSAdvValue( oResponse,"_DEPARTMENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescriptionShort  :=  WSAdvValue( oResponse,"_DESCRIPTIONSHORT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsVisible         :=  WSAdvValue( oResponse,"_ISVISIBLE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cKeyWords          :=  WSAdvValue( oResponse,"_KEYWORDS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLinkId            :=  WSAdvValue( oResponse,"_LINKID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode12 :=  WSAdvValue( oResponse,"_LISTSTOREID","ArrayOfint",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSListStoreId := Service_ArrayOfint():New()
		::oWSListStoreId:SoapRecv(oNode12)
	EndIf
	::cLomadeeCampaignCode :=  WSAdvValue( oResponse,"_LOMADEECAMPAIGNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMetaTagDescription :=  WSAdvValue( oResponse,"_METATAGDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRefId             :=  WSAdvValue( oResponse,"_REFID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cReleaseDate       :=  WSAdvValue( oResponse,"_RELEASEDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::nScore             :=  WSAdvValue( oResponse,"_SCORE","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lShowWithoutStock  :=  WSAdvValue( oResponse,"_SHOWWITHOUTSTOCK","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nSupplierId        :=  WSAdvValue( oResponse,"_SUPPLIERID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cTaxCode           :=  WSAdvValue( oResponse,"_TAXCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTitle             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfint

WSSTRUCT Service_ArrayOfint
	WSDATA   nint                      AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfint
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfint
	::nint                 := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfint
	Local oClone := Service_ArrayOfint():NEW()
	oClone:nint                 := IIf(::nint <> NIL , aClone(::nint) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfint
	Local cSoap := ""
	aEval( ::nint , {|x| cSoap := cSoap  +  WSSoapValue("int", x , x , "int", .F. , .F., 0 , "http://schemas.microsoft.com/2003/10/Serialization/Arrays", .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfint
	Local oNodes1 :=  WSAdvValue( oResponse,"_INT","int",{},NIL,.T.,"N",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::nint ,  val(x:TEXT)  ) } )
Return

// WSDL Data Structure ArrayOfProductDTO

WSSTRUCT Service_ArrayOfProductDTO
	WSDATA   oWSProductDTO             AS Service_ProductDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfProductDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfProductDTO
	::oWSProductDTO        := {} // Array Of  Service_PRODUCTDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfProductDTO
	Local oClone := Service_ArrayOfProductDTO():NEW()
	oClone:oWSProductDTO := NIL
	If ::oWSProductDTO <> NIL 
		oClone:oWSProductDTO := {}
		aEval( ::oWSProductDTO , { |x| aadd( oClone:oWSProductDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfProductDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PRODUCTDTO","ProductDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSProductDTO , Service_ProductDTO():New() )
			::oWSProductDTO[len(::oWSProductDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfStockKeepingUnitKitDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitKitDTO
	WSDATA   oWSStockKeepingUnitKitDTO AS Service_StockKeepingUnitKitDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitKitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitKitDTO
	::oWSStockKeepingUnitKitDTO := {} // Array Of  Service_STOCKKEEPINGUNITKITDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitKitDTO
	Local oClone := Service_ArrayOfStockKeepingUnitKitDTO():NEW()
	oClone:oWSStockKeepingUnitKitDTO := NIL
	If ::oWSStockKeepingUnitKitDTO <> NIL 
		oClone:oWSStockKeepingUnitKitDTO := {}
		aEval( ::oWSStockKeepingUnitKitDTO , { |x| aadd( oClone:oWSStockKeepingUnitKitDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfStockKeepingUnitKitDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITKITDTO","StockKeepingUnitKitDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStockKeepingUnitKitDTO , Service_StockKeepingUnitKitDTO():New() )
			::oWSStockKeepingUnitKitDTO[len(::oWSStockKeepingUnitKitDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure StockKeepingUnitKitDTO

WSSTRUCT Service_StockKeepingUnitKitDTO
	WSDATA   nAmount                   AS int OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSDATA   nStockKeepingUnitParent   AS int OPTIONAL
	WSDATA   nUnitPrice                AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitKitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitKitDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitKitDTO
	Local oClone := Service_StockKeepingUnitKitDTO():NEW()
	oClone:nAmount              := ::nAmount
	oClone:nId                  := ::nId
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
	oClone:nStockKeepingUnitParent := ::nStockKeepingUnitParent
	oClone:nUnitPrice           := ::nUnitPrice
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitKitDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Amount", ::nAmount, ::nAmount , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitParent", ::nStockKeepingUnitParent, ::nStockKeepingUnitParent , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("UnitPrice", ::nUnitPrice, ::nUnitPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StockKeepingUnitKitDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAmount            :=  WSAdvValue( oResponse,"_AMOUNT","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nStockKeepingUnitId :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nStockKeepingUnitParent :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITPARENT","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nUnitPrice         :=  WSAdvValue( oResponse,"_UNITPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ServiceDTO

WSSTRUCT Service_ServiceDTO
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   lIsFile                   AS boolean OPTIONAL
	WSDATA   lIsGiftCard               AS boolean OPTIONAL
	WSDATA   lIsRequired               AS boolean OPTIONAL
	WSDATA   lIsVisibleOnCart          AS boolean OPTIONAL
	WSDATA   lIsVisibleOnProduct       AS boolean OPTIONAL
	WSDATA   lIsVisibleOnService       AS boolean OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ServiceDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ServiceDTO
Return

WSMETHOD CLONE WSCLIENT Service_ServiceDTO
	Local oClone := Service_ServiceDTO():NEW()
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:lIsFile              := ::lIsFile
	oClone:lIsGiftCard          := ::lIsGiftCard
	oClone:lIsRequired          := ::lIsRequired
	oClone:lIsVisibleOnCart     := ::lIsVisibleOnCart
	oClone:lIsVisibleOnProduct  := ::lIsVisibleOnProduct
	oClone:lIsVisibleOnService  := ::lIsVisibleOnService
	oClone:cName                := ::cName
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ServiceDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsFile", ::lIsFile, ::lIsFile , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsGiftCard", ::lIsGiftCard, ::lIsGiftCard , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsRequired", ::lIsRequired, ::lIsRequired , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsVisibleOnCart", ::lIsVisibleOnCart, ::lIsVisibleOnCart , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsVisibleOnProduct", ::lIsVisibleOnProduct, ::lIsVisibleOnProduct , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsVisibleOnService", ::lIsVisibleOnService, ::lIsVisibleOnService , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ServiceDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsFile            :=  WSAdvValue( oResponse,"_ISFILE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsGiftCard        :=  WSAdvValue( oResponse,"_ISGIFTCARD","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsRequired        :=  WSAdvValue( oResponse,"_ISREQUIRED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsVisibleOnCart   :=  WSAdvValue( oResponse,"_ISVISIBLEONCART","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsVisibleOnProduct :=  WSAdvValue( oResponse,"_ISVISIBLEONPRODUCT","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsVisibleOnService :=  WSAdvValue( oResponse,"_ISVISIBLEONSERVICE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ServicePriceDTO

WSSTRUCT Service_ServicePriceDTO
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   nListPrice                AS decimal OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nPrice                    AS decimal OPTIONAL
	WSDATA   oWSService                AS Service_ServiceDTO OPTIONAL
	WSDATA   nServiceId                AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ServicePriceDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ServicePriceDTO
Return

WSMETHOD CLONE WSCLIENT Service_ServicePriceDTO
	Local oClone := Service_ServicePriceDTO():NEW()
	oClone:nId                  := ::nId
	oClone:nListPrice           := ::nListPrice
	oClone:cName                := ::cName
	oClone:nPrice               := ::nPrice
	oClone:oWSService           := IIF(::oWSService = NIL , NIL , ::oWSService:Clone() )
	oClone:nServiceId           := ::nServiceId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ServicePriceDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ListPrice", ::nListPrice, ::nListPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Price", ::nPrice, ::nPrice , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Service", ::oWSService, ::oWSService , "ServiceDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ServiceId", ::nServiceId, ::nServiceId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ServicePriceDTO
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nListPrice         :=  WSAdvValue( oResponse,"_LISTPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPrice             :=  WSAdvValue( oResponse,"_PRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_SERVICE","ServiceDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSService := Service_ServiceDTO():New()
		::oWSService:SoapRecv(oNode5)
	EndIf
	::nServiceId         :=  WSAdvValue( oResponse,"_SERVICEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfServicePriceDTO

WSSTRUCT Service_ArrayOfServicePriceDTO
	WSDATA   oWSServicePriceDTO        AS Service_ServicePriceDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfServicePriceDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfServicePriceDTO
	::oWSServicePriceDTO   := {} // Array Of  Service_SERVICEPRICEDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfServicePriceDTO
	Local oClone := Service_ArrayOfServicePriceDTO():NEW()
	oClone:oWSServicePriceDTO := NIL
	If ::oWSServicePriceDTO <> NIL 
		oClone:oWSServicePriceDTO := {}
		aEval( ::oWSServicePriceDTO , { |x| aadd( oClone:oWSServicePriceDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfServicePriceDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SERVICEPRICEDTO","ServicePriceDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSServicePriceDTO , Service_ServicePriceDTO():New() )
			::oWSServicePriceDTO[len(::oWSServicePriceDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure StockKeepingUnitServiceDTO

WSSTRUCT Service_StockKeepingUnitServiceDTO
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nServiceId                AS int OPTIONAL
	WSDATA   oWSServicePrice           AS Service_ServicePriceDTO OPTIONAL
	WSDATA   nServicePriceId           AS int OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitServiceDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitServiceDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitServiceDTO
	Local oClone := Service_StockKeepingUnitServiceDTO():NEW()
	oClone:cDescription         := ::cDescription
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:cName                := ::cName
	oClone:nServiceId           := ::nServiceId
	oClone:oWSServicePrice      := IIF(::oWSServicePrice = NIL , NIL , ::oWSServicePrice:Clone() )
	oClone:nServicePriceId      := ::nServicePriceId
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitServiceDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ServiceId", ::nServiceId, ::nServiceId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ServicePrice", ::oWSServicePrice, ::oWSServicePrice , "ServicePriceDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ServicePriceId", ::nServicePriceId, ::nServicePriceId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StockKeepingUnitServiceDTO
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nServiceId         :=  WSAdvValue( oResponse,"_SERVICEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_SERVICEPRICE","ServicePriceDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSServicePrice := Service_ServicePriceDTO():New()
		::oWSServicePrice:SoapRecv(oNode6)
	EndIf
	::nServicePriceId    :=  WSAdvValue( oResponse,"_SERVICEPRICEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nStockKeepingUnitId :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITID","int",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfStockKeepingUnitServiceDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitServiceDTO
	WSDATA   oWSStockKeepingUnitServiceDTO AS Service_StockKeepingUnitServiceDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitServiceDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitServiceDTO
	::oWSStockKeepingUnitServiceDTO := {} // Array Of  Service_STOCKKEEPINGUNITSERVICEDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitServiceDTO
	Local oClone := Service_ArrayOfStockKeepingUnitServiceDTO():NEW()
	oClone:oWSStockKeepingUnitServiceDTO := NIL
	If ::oWSStockKeepingUnitServiceDTO <> NIL 
		oClone:oWSStockKeepingUnitServiceDTO := {}
		aEval( ::oWSStockKeepingUnitServiceDTO , { |x| aadd( oClone:oWSStockKeepingUnitServiceDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfStockKeepingUnitServiceDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITSERVICEDTO","StockKeepingUnitServiceDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStockKeepingUnitServiceDTO , Service_StockKeepingUnitServiceDTO():New() )
			::oWSStockKeepingUnitServiceDTO[len(::oWSStockKeepingUnitServiceDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure BrandDTO

WSSTRUCT Service_BrandDTO
	WSDATA   cAdWordsRemarketingCode   AS string OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   cKeywords                 AS string OPTIONAL
	WSDATA   cLomadeeCampaignCode      AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nScore                    AS int OPTIONAL
	WSDATA   cTitle                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_BrandDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_BrandDTO
Return

WSMETHOD CLONE WSCLIENT Service_BrandDTO
	Local oClone := Service_BrandDTO():NEW()
	oClone:cAdWordsRemarketingCode := ::cAdWordsRemarketingCode
	oClone:cDescription         := ::cDescription
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:cKeywords            := ::cKeywords
	oClone:cLomadeeCampaignCode := ::cLomadeeCampaignCode
	oClone:cName                := ::cName
	oClone:nScore               := ::nScore
	oClone:cTitle               := ::cTitle
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_BrandDTO
	Local cSoap := ""
	cSoap += WSSoapValue("AdWordsRemarketingCode", ::cAdWordsRemarketingCode, ::cAdWordsRemarketingCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Keywords", ::cKeywords, ::cKeywords , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("LomadeeCampaignCode", ::cLomadeeCampaignCode, ::cLomadeeCampaignCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Score", ::nScore, ::nScore , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Title", ::cTitle, ::cTitle , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_BrandDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAdWordsRemarketingCode :=  WSAdvValue( oResponse,"_ADWORDSREMARKETINGCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cKeywords          :=  WSAdvValue( oResponse,"_KEYWORDS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLomadeeCampaignCode :=  WSAdvValue( oResponse,"_LOMADEECAMPAIGNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nScore             :=  WSAdvValue( oResponse,"_SCORE","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cTitle             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CategoryDTO

WSSTRUCT Service_CategoryDTO
	WSDATA   cAdWordsRemarketingCode   AS string OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nFatherCategoryId         AS int OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   cKeywords                 AS string OPTIONAL
	WSDATA   cLomadeeCampaignCode      AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nScore                    AS int OPTIONAL
	WSDATA   lShowBrandFilter          AS boolean OPTIONAL
	WSDATA   cTitle                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_CategoryDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_CategoryDTO
Return

WSMETHOD CLONE WSCLIENT Service_CategoryDTO
	Local oClone := Service_CategoryDTO():NEW()
	oClone:cAdWordsRemarketingCode := ::cAdWordsRemarketingCode
	oClone:cDescription         := ::cDescription
	oClone:nFatherCategoryId    := ::nFatherCategoryId
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:cKeywords            := ::cKeywords
	oClone:cLomadeeCampaignCode := ::cLomadeeCampaignCode
	oClone:cName                := ::cName
	oClone:nScore               := ::nScore
	oClone:lShowBrandFilter     := ::lShowBrandFilter
	oClone:cTitle               := ::cTitle
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_CategoryDTO
	Local cSoap := ""
	cSoap += WSSoapValue("AdWordsRemarketingCode", ::cAdWordsRemarketingCode, ::cAdWordsRemarketingCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("FatherCategoryId", ::nFatherCategoryId, ::nFatherCategoryId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Keywords", ::cKeywords, ::cKeywords , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("LomadeeCampaignCode", ::cLomadeeCampaignCode, ::cLomadeeCampaignCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Score", ::nScore, ::nScore , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ShowBrandFilter", ::lShowBrandFilter, ::lShowBrandFilter , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Title", ::cTitle, ::cTitle , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_CategoryDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAdWordsRemarketingCode :=  WSAdvValue( oResponse,"_ADWORDSREMARKETINGCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFatherCategoryId  :=  WSAdvValue( oResponse,"_FATHERCATEGORYID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cKeywords          :=  WSAdvValue( oResponse,"_KEYWORDS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLomadeeCampaignCode :=  WSAdvValue( oResponse,"_LOMADEECAMPAIGNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nScore             :=  WSAdvValue( oResponse,"_SCORE","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lShowBrandFilter   :=  WSAdvValue( oResponse,"_SHOWBRANDFILTER","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cTitle             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfImageDTO

WSSTRUCT Service_ArrayOfImageDTO
	WSDATA   oWSImageDTO               AS Service_ImageDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfImageDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfImageDTO
	::oWSImageDTO          := {} // Array Of  Service_IMAGEDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfImageDTO
	Local oClone := Service_ArrayOfImageDTO():NEW()
	oClone:oWSImageDTO := NIL
	If ::oWSImageDTO <> NIL 
		oClone:oWSImageDTO := {}
		aEval( ::oWSImageDTO , { |x| aadd( oClone:oWSImageDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfImageDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_IMAGEDTO","ImageDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSImageDTO , Service_ImageDTO():New() )
			::oWSImageDTO[len(::oWSImageDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfFieldDTO

WSSTRUCT Service_ArrayOfFieldDTO
	WSDATA   oWSFieldDTO               AS Service_FieldDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFieldDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFieldDTO
	::oWSFieldDTO          := {} // Array Of  Service_FIELDDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFieldDTO
	Local oClone := Service_ArrayOfFieldDTO():NEW()
	oClone:oWSFieldDTO := NIL
	If ::oWSFieldDTO <> NIL 
		oClone:oWSFieldDTO := {}
		aEval( ::oWSFieldDTO , { |x| aadd( oClone:oWSFieldDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfFieldDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FIELDDTO","FieldDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFieldDTO , Service_FieldDTO():New() )
			::oWSFieldDTO[len(::oWSFieldDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure StockKeepingUnitComplementDTO

WSSTRUCT Service_StockKeepingUnitComplementDTO
	//WSDATA   oWSComplementType         AS Service_StockKeepingUnitComplementDTO.ComplementTypeEnum OPTIONAL
	WSDATA   oWSStockKeepingUnitComplements AS Service_ArrayOfint OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitComplementDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitComplementDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitComplementDTO
	Local oClone := Service_StockKeepingUnitComplementDTO():NEW()
	oClone:oWSComplementType    := IIF(::oWSComplementType = NIL , NIL , ::oWSComplementType:Clone() )
	oClone:oWSStockKeepingUnitComplements := IIF(::oWSStockKeepingUnitComplements = NIL , NIL , ::oWSStockKeepingUnitComplements:Clone() )
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitComplementDTO
	Local cSoap := ""
	cSoap += WSSoapValue("ComplementType", ::oWSComplementType, ::oWSComplementType , "StockKeepingUnitComplementDTO.ComplementTypeEnum", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitComplements", ::oWSStockKeepingUnitComplements, ::oWSStockKeepingUnitComplements , "ArrayOfint", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfstring

WSSTRUCT Service_ArrayOfstring
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfstring
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfstring
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfstring
	Local oClone := Service_ArrayOfstring():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfstring
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , "http://schemas.microsoft.com/2003/10/Serialization/Arrays", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfProductFieldNameDTO

WSSTRUCT Service_ArrayOfProductFieldNameDTO
	WSDATA   oWSProductFieldNameDTO    AS Service_ProductFieldNameDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfProductFieldNameDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfProductFieldNameDTO
	::oWSProductFieldNameDTO := {} // Array Of  Service_PRODUCTFIELDNAMEDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfProductFieldNameDTO
	Local oClone := Service_ArrayOfProductFieldNameDTO():NEW()
	oClone:oWSProductFieldNameDTO := NIL
	If ::oWSProductFieldNameDTO <> NIL 
		oClone:oWSProductFieldNameDTO := {}
		aEval( ::oWSProductFieldNameDTO , { |x| aadd( oClone:oWSProductFieldNameDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfProductFieldNameDTO
	Local cSoap := ""
	aEval( ::oWSProductFieldNameDTO , {|x| cSoap := cSoap  +  WSSoapValue("ProductFieldNameDTO", x , x , "ProductFieldNameDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfProductFieldIdDTO

WSSTRUCT Service_ArrayOfProductFieldIdDTO
	WSDATA   oWSProductFieldIdDTO      AS Service_ProductFieldIdDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfProductFieldIdDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfProductFieldIdDTO
	::oWSProductFieldIdDTO := {} // Array Of  Service_PRODUCTFIELDIDDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfProductFieldIdDTO
	Local oClone := Service_ArrayOfProductFieldIdDTO():NEW()
	oClone:oWSProductFieldIdDTO := NIL
	If ::oWSProductFieldIdDTO <> NIL 
		oClone:oWSProductFieldIdDTO := {}
		aEval( ::oWSProductFieldIdDTO , { |x| aadd( oClone:oWSProductFieldIdDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfProductFieldIdDTO
	Local cSoap := ""
	aEval( ::oWSProductFieldIdDTO , {|x| cSoap := cSoap  +  WSSoapValue("ProductFieldIdDTO", x , x , "ProductFieldIdDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStockKeepingUnitFieldNameDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitFieldNameDTO
	WSDATA   oWSStockKeepingUnitFieldNameDTO AS Service_StockKeepingUnitFieldNameDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitFieldNameDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitFieldNameDTO
	::oWSStockKeepingUnitFieldNameDTO := {} // Array Of  Service_STOCKKEEPINGUNITFIELDNAMEDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitFieldNameDTO
	Local oClone := Service_ArrayOfStockKeepingUnitFieldNameDTO():NEW()
	oClone:oWSStockKeepingUnitFieldNameDTO := NIL
	If ::oWSStockKeepingUnitFieldNameDTO <> NIL 
		oClone:oWSStockKeepingUnitFieldNameDTO := {}
		aEval( ::oWSStockKeepingUnitFieldNameDTO , { |x| aadd( oClone:oWSStockKeepingUnitFieldNameDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfStockKeepingUnitFieldNameDTO
	Local cSoap := ""
	aEval( ::oWSStockKeepingUnitFieldNameDTO , {|x| cSoap := cSoap  +  WSSoapValue("StockKeepingUnitFieldNameDTO", x , x , "StockKeepingUnitFieldNameDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStoreDTO

WSSTRUCT Service_ArrayOfStoreDTO
	WSDATA   oWSStoreDTO               AS Service_StoreDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStoreDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStoreDTO
	::oWSStoreDTO          := {} // Array Of  Service_STOREDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStoreDTO
	Local oClone := Service_ArrayOfStoreDTO():NEW()
	oClone:oWSStoreDTO := NIL
	If ::oWSStoreDTO <> NIL 
		oClone:oWSStoreDTO := {}
		aEval( ::oWSStoreDTO , { |x| aadd( oClone:oWSStoreDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfStoreDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STOREDTO","StoreDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStoreDTO , Service_StoreDTO():New() )
			::oWSStoreDTO[len(::oWSStoreDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure StoreDTO

WSSTRUCT Service_StoreDTO
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StoreDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StoreDTO
Return

WSMETHOD CLONE WSCLIENT Service_StoreDTO
	Local oClone := Service_StoreDTO():NEW()
	oClone:nId                  := ::nId
	oClone:lIsActive            := ::lIsActive
	oClone:cName                := ::cName
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StoreDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GiftCardDTO

WSSTRUCT Service_GiftCardDTO
	WSDATA   cEmissionDate             AS dateTime OPTIONAL
	WSDATA   cExpiringDate             AS dateTime OPTIONAL
	WSDATA   nFunds                    AS decimal OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lMultipleCredits          AS boolean OPTIONAL
	WSDATA   lMultipleRedemptions      AS boolean OPTIONAL
	WSDATA   cOwnerId                  AS string OPTIONAL
	WSDATA   cRedeptionCode            AS string OPTIONAL
	WSDATA   lRestrictedToOwner        AS boolean OPTIONAL
	WSDATA   nStatusId                 AS short OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftCardDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftCardDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftCardDTO
	Local oClone := Service_GiftCardDTO():NEW()
	oClone:cEmissionDate        := ::cEmissionDate
	oClone:cExpiringDate        := ::cExpiringDate
	oClone:nFunds               := ::nFunds
	oClone:nId                  := ::nId
	oClone:lMultipleCredits     := ::lMultipleCredits
	oClone:lMultipleRedemptions := ::lMultipleRedemptions
	oClone:cOwnerId             := ::cOwnerId
	oClone:cRedeptionCode       := ::cRedeptionCode
	oClone:lRestrictedToOwner   := ::lRestrictedToOwner
	oClone:nStatusId            := ::nStatusId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GiftCardDTO
	Local cSoap := ""
	cSoap += WSSoapValue("EmissionDate", ::cEmissionDate, ::cEmissionDate , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ExpiringDate", ::cExpiringDate, ::cExpiringDate , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Funds", ::nFunds, ::nFunds , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("MultipleCredits", ::lMultipleCredits, ::lMultipleCredits , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("MultipleRedemptions", ::lMultipleRedemptions, ::lMultipleRedemptions , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OwnerId", ::cOwnerId, ::cOwnerId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RedeptionCode", ::cRedeptionCode, ::cRedeptionCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RestrictedToOwner", ::lRestrictedToOwner, ::lRestrictedToOwner , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StatusId", ::nStatusId, ::nStatusId , "short", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_GiftCardDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEmissionDate      :=  WSAdvValue( oResponse,"_EMISSIONDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cExpiringDate      :=  WSAdvValue( oResponse,"_EXPIRINGDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFunds             :=  WSAdvValue( oResponse,"_FUNDS","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lMultipleCredits   :=  WSAdvValue( oResponse,"_MULTIPLECREDITS","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lMultipleRedemptions :=  WSAdvValue( oResponse,"_MULTIPLEREDEMPTIONS","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cOwnerId           :=  WSAdvValue( oResponse,"_OWNERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRedeptionCode     :=  WSAdvValue( oResponse,"_REDEPTIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lRestrictedToOwner :=  WSAdvValue( oResponse,"_RESTRICTEDTOOWNER","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nStatusId          :=  WSAdvValue( oResponse,"_STATUSID","short",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure GiftCardTransactionItemDTO

WSSTRUCT Service_GiftCardTransactionItemDTO
	WSDATA   nOrderId                  AS int OPTIONAL
	WSDATA   cRedemptionCode           AS string OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSDATA   oWSTransactionAction      AS Service_TransactionAction OPTIONAL
	WSDATA   lTransactionConfirmed     AS boolean OPTIONAL
	WSDATA   nValue                    AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftCardTransactionItemDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftCardTransactionItemDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftCardTransactionItemDTO
	Local oClone := Service_GiftCardTransactionItemDTO():NEW()
	oClone:nOrderId             := ::nOrderId
	oClone:cRedemptionCode      := ::cRedemptionCode
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
	oClone:oWSTransactionAction := IIF(::oWSTransactionAction = NIL , NIL , ::oWSTransactionAction:Clone() )
	oClone:lTransactionConfirmed := ::lTransactionConfirmed
	oClone:nValue               := ::nValue
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GiftCardTransactionItemDTO
	Local cSoap := ""
	cSoap += WSSoapValue("OrderId", ::nOrderId, ::nOrderId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("RedemptionCode", ::cRedemptionCode, ::cRedemptionCode , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("TransactionAction", ::oWSTransactionAction, ::oWSTransactionAction , "TransactionAction", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("TransactionConfirmed", ::lTransactionConfirmed, ::lTransactionConfirmed , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Value", ::nValue, ::nValue , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Structure GiftListDTO

WSSTRUCT Service_GiftListDTO
	WSDATA   nClientAddressId          AS int OPTIONAL
	WSDATA   nClientId                 AS int OPTIONAL
	WSDATA   cDateCreated              AS dateTime OPTIONAL
	WSDATA   cDateModified             AS dateTime OPTIONAL
	WSDATA   cEventCity                AS string OPTIONAL
	WSDATA   cEventDate                AS dateTime OPTIONAL
	WSDATA   cEventLocation            AS string OPTIONAL
	WSDATA   cEventState               AS string OPTIONAL
	WSDATA   nFileId                   AS int OPTIONAL
	WSDATA   nGiftCardId               AS int OPTIONAL
	WSDATA   nGiftListId               AS int OPTIONAL
	WSDATA   oWSGiftListMembers        AS Service_ArrayOfGiftListMemberDTO OPTIONAL
	WSDATA   nGiftListTypeId           AS int OPTIONAL
	WSDATA   cGifted                   AS string OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   lIsPublic                 AS boolean OPTIONAL
	WSDATA   cMessage                  AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   cProfileSystemUserAddressName AS string OPTIONAL
	WSDATA   cProfileSystemUserId      AS string OPTIONAL
	WSDATA   cUrlFolder                AS string OPTIONAL
	WSDATA   nVersion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftListDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftListDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftListDTO
	Local oClone := Service_GiftListDTO():NEW()
	oClone:nClientAddressId     := ::nClientAddressId
	oClone:nClientId            := ::nClientId
	oClone:cDateCreated         := ::cDateCreated
	oClone:cDateModified        := ::cDateModified
	oClone:cEventCity           := ::cEventCity
	oClone:cEventDate           := ::cEventDate
	oClone:cEventLocation       := ::cEventLocation
	oClone:cEventState          := ::cEventState
	oClone:nFileId              := ::nFileId
	oClone:nGiftCardId          := ::nGiftCardId
	oClone:nGiftListId          := ::nGiftListId
	oClone:oWSGiftListMembers   := IIF(::oWSGiftListMembers = NIL , NIL , ::oWSGiftListMembers:Clone() )
	oClone:nGiftListTypeId      := ::nGiftListTypeId
	oClone:cGifted              := ::cGifted
	oClone:lIsActive            := ::lIsActive
	oClone:lIsPublic            := ::lIsPublic
	oClone:cMessage             := ::cMessage
	oClone:cName                := ::cName
	oClone:cProfileSystemUserAddressName := ::cProfileSystemUserAddressName
	oClone:cProfileSystemUserId := ::cProfileSystemUserId
	oClone:cUrlFolder           := ::cUrlFolder
	oClone:nVersion             := ::nVersion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GiftListDTO
	Local cSoap := ""
	cSoap += WSSoapValue("ClientAddressId", ::nClientAddressId, ::nClientAddressId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ClientId", ::nClientId, ::nClientId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DateCreated", ::cDateCreated, ::cDateCreated , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DateModified", ::cDateModified, ::cDateModified , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("EventCity", ::cEventCity, ::cEventCity , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("EventDate", ::cEventDate, ::cEventDate , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("EventLocation", ::cEventLocation, ::cEventLocation , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("EventState", ::cEventState, ::cEventState , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("FileId", ::nFileId, ::nFileId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftCardId", ::nGiftCardId, ::nGiftCardId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListId", ::nGiftListId, ::nGiftListId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListMembers", ::oWSGiftListMembers, ::oWSGiftListMembers , "ArrayOfGiftListMemberDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListTypeId", ::nGiftListTypeId, ::nGiftListTypeId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Gifted", ::cGifted, ::cGifted , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsPublic", ::lIsPublic, ::lIsPublic , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Message", ::cMessage, ::cMessage , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ProfileSystemUserAddressName", ::cProfileSystemUserAddressName, ::cProfileSystemUserAddressName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ProfileSystemUserId", ::cProfileSystemUserId, ::cProfileSystemUserId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("UrlFolder", ::cUrlFolder, ::cUrlFolder , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Version", ::nVersion, ::nVersion , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_GiftListDTO
	Local oNode12
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nClientAddressId   :=  WSAdvValue( oResponse,"_CLIENTADDRESSID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nClientId          :=  WSAdvValue( oResponse,"_CLIENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDateCreated       :=  WSAdvValue( oResponse,"_DATECREATED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDateModified      :=  WSAdvValue( oResponse,"_DATEMODIFIED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEventCity         :=  WSAdvValue( oResponse,"_EVENTCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEventDate         :=  WSAdvValue( oResponse,"_EVENTDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEventLocation     :=  WSAdvValue( oResponse,"_EVENTLOCATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEventState        :=  WSAdvValue( oResponse,"_EVENTSTATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFileId            :=  WSAdvValue( oResponse,"_FILEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftCardId        :=  WSAdvValue( oResponse,"_GIFTCARDID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftListId        :=  WSAdvValue( oResponse,"_GIFTLISTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode12 :=  WSAdvValue( oResponse,"_GIFTLISTMEMBERS","ArrayOfGiftListMemberDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSGiftListMembers := Service_ArrayOfGiftListMemberDTO():New()
		::oWSGiftListMembers:SoapRecv(oNode12)
	EndIf
	::nGiftListTypeId    :=  WSAdvValue( oResponse,"_GIFTLISTTYPEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cGifted            :=  WSAdvValue( oResponse,"_GIFTED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsPublic          :=  WSAdvValue( oResponse,"_ISPUBLIC","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cMessage           :=  WSAdvValue( oResponse,"_MESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProfileSystemUserAddressName :=  WSAdvValue( oResponse,"_PROFILESYSTEMUSERADDRESSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProfileSystemUserId :=  WSAdvValue( oResponse,"_PROFILESYSTEMUSERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUrlFolder         :=  WSAdvValue( oResponse,"_URLFOLDER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nVersion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfGiftListDTO

WSSTRUCT Service_ArrayOfGiftListDTO
	WSDATA   oWSGiftListDTO            AS Service_GiftListDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfGiftListDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfGiftListDTO
	::oWSGiftListDTO       := {} // Array Of  Service_GIFTLISTDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfGiftListDTO
	Local oClone := Service_ArrayOfGiftListDTO():NEW()
	oClone:oWSGiftListDTO := NIL
	If ::oWSGiftListDTO <> NIL 
		oClone:oWSGiftListDTO := {}
		aEval( ::oWSGiftListDTO , { |x| aadd( oClone:oWSGiftListDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfGiftListDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GIFTLISTDTO","GiftListDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGiftListDTO , Service_GiftListDTO():New() )
			::oWSGiftListDTO[len(::oWSGiftListDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure GiftListTypeDTO

WSSTRUCT Service_GiftListTypeDTO
	WSDATA   nGiftListTypeId           AS int OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   lIsMessageAvailable       AS boolean OPTIONAL
	WSDATA   lIsStockImpact            AS boolean OPTIONAL
	WSDATA   lShipToListOwner          AS boolean OPTIONAL
	WSDATA   nDaysToExpireToVisitors   AS int OPTIONAL
	WSDATA   nDaysToExpireToMembers    AS int OPTIONAL
	WSDATA   nDaysToEventMin           AS int OPTIONAL
	WSDATA   nDaysToEventMax           AS int OPTIONAL
	WSDATA   nMemberMin                AS int OPTIONAL
	WSDATA   nMemberMax                AS int OPTIONAL
	WSDATA   cMemberTitle              AS string OPTIONAL
	WSDATA   cTextTitle1               AS string OPTIONAL
	WSDATA   cTextTitle2               AS string OPTIONAL
	WSDATA   lIsPublic                 AS boolean OPTIONAL
	WSDATA   lIsProtected              AS boolean OPTIONAL
	WSDATA   lIsUnique                 AS boolean OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   nVersion                  AS int OPTIONAL
	WSDATA   nGiftCardRechargeSkuId    AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftListTypeDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftListTypeDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftListTypeDTO
	Local oClone := Service_GiftListTypeDTO():NEW()
	oClone:nGiftListTypeId      := ::nGiftListTypeId
	oClone:cName                := ::cName
	oClone:cDescription         := ::cDescription
	oClone:lIsMessageAvailable  := ::lIsMessageAvailable
	oClone:lIsStockImpact       := ::lIsStockImpact
	oClone:lShipToListOwner     := ::lShipToListOwner
	oClone:nDaysToExpireToVisitors := ::nDaysToExpireToVisitors
	oClone:nDaysToExpireToMembers := ::nDaysToExpireToMembers
	oClone:nDaysToEventMin      := ::nDaysToEventMin
	oClone:nDaysToEventMax      := ::nDaysToEventMax
	oClone:nMemberMin           := ::nMemberMin
	oClone:nMemberMax           := ::nMemberMax
	oClone:cMemberTitle         := ::cMemberTitle
	oClone:cTextTitle1          := ::cTextTitle1
	oClone:cTextTitle2          := ::cTextTitle2
	oClone:lIsPublic            := ::lIsPublic
	oClone:lIsProtected         := ::lIsProtected
	oClone:lIsUnique            := ::lIsUnique
	oClone:lIsActive            := ::lIsActive
	oClone:nVersion             := ::nVersion
	oClone:nGiftCardRechargeSkuId := ::nGiftCardRechargeSkuId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_GiftListTypeDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nGiftListTypeId    :=  WSAdvValue( oResponse,"_GIFTLISTTYPEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsMessageAvailable :=  WSAdvValue( oResponse,"_ISMESSAGEAVAILABLE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsStockImpact     :=  WSAdvValue( oResponse,"_ISSTOCKIMPACT","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lShipToListOwner   :=  WSAdvValue( oResponse,"_SHIPTOLISTOWNER","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nDaysToExpireToVisitors :=  WSAdvValue( oResponse,"_DAYSTOEXPIRETOVISITORS","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDaysToExpireToMembers :=  WSAdvValue( oResponse,"_DAYSTOEXPIRETOMEMBERS","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDaysToEventMin    :=  WSAdvValue( oResponse,"_DAYSTOEVENTMIN","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDaysToEventMax    :=  WSAdvValue( oResponse,"_DAYSTOEVENTMAX","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nMemberMin         :=  WSAdvValue( oResponse,"_MEMBERMIN","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nMemberMax         :=  WSAdvValue( oResponse,"_MEMBERMAX","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cMemberTitle       :=  WSAdvValue( oResponse,"_MEMBERTITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTextTitle1        :=  WSAdvValue( oResponse,"_TEXTTITLE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTextTitle2        :=  WSAdvValue( oResponse,"_TEXTTITLE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsPublic          :=  WSAdvValue( oResponse,"_ISPUBLIC","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsProtected       :=  WSAdvValue( oResponse,"_ISPROTECTED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsUnique          :=  WSAdvValue( oResponse,"_ISUNIQUE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nVersion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftCardRechargeSkuId :=  WSAdvValue( oResponse,"_GIFTCARDRECHARGESKUID","int",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfGiftListMemberDTO

WSSTRUCT Service_ArrayOfGiftListMemberDTO
	WSDATA   oWSGiftListMemberDTO      AS Service_GiftListMemberDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfGiftListMemberDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfGiftListMemberDTO
	::oWSGiftListMemberDTO := {} // Array Of  Service_GIFTLISTMEMBERDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfGiftListMemberDTO
	Local oClone := Service_ArrayOfGiftListMemberDTO():NEW()
	oClone:oWSGiftListMemberDTO := NIL
	If ::oWSGiftListMemberDTO <> NIL 
		oClone:oWSGiftListMemberDTO := {}
		aEval( ::oWSGiftListMemberDTO , { |x| aadd( oClone:oWSGiftListMemberDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfGiftListMemberDTO
	Local cSoap := ""
	aEval( ::oWSGiftListMemberDTO , {|x| cSoap := cSoap  +  WSSoapValue("GiftListMemberDTO", x , x , "GiftListMemberDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfGiftListMemberDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GIFTLISTMEMBERDTO","GiftListMemberDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGiftListMemberDTO , Service_GiftListMemberDTO():New() )
			::oWSGiftListMemberDTO[len(::oWSGiftListMemberDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure GiftListStockKeepingUnitDTO

WSSTRUCT Service_GiftListStockKeepingUnitDTO
	WSDATA   cDateCreated              AS dateTime OPTIONAL
	WSDATA   cDatePurchased            AS dateTime OPTIONAL
	WSDATA   nFreightAndServicesValue  AS decimal OPTIONAL
	WSDATA   nGiftListId               AS int OPTIONAL
	WSDATA   nGiftListSkuId            AS int OPTIONAL
	WSDATA   nInsertedByClientId       AS int OPTIONAL
	WSDATA   cInsertedByProfileSystemUserId AS string OPTIONAL
	WSDATA   nItemValue                AS decimal OPTIONAL
	WSDATA   cOmsOrderId               AS string OPTIONAL
	WSDATA   nOrderId                  AS int OPTIONAL
	WSDATA   cOrderMessage             AS string OPTIONAL
	WSDATA   cOrderMessageFrom         AS string OPTIONAL
	WSDATA   cOrderMessageTo           AS string OPTIONAL
	WSDATA   cOrderResponseMessage     AS string OPTIONAL
	WSDATA   nSkuId                    AS int OPTIONAL
	WSDATA   nWishedByClientId         AS int OPTIONAL
	WSDATA   cWishedByProfileSystemUserId AS string OPTIONAL
	WSDATA   l_IsOrderFinished         AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftListStockKeepingUnitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftListStockKeepingUnitDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftListStockKeepingUnitDTO
	Local oClone := Service_GiftListStockKeepingUnitDTO():NEW()
	oClone:cDateCreated         := ::cDateCreated
	oClone:cDatePurchased       := ::cDatePurchased
	oClone:nFreightAndServicesValue := ::nFreightAndServicesValue
	oClone:nGiftListId          := ::nGiftListId
	oClone:nGiftListSkuId       := ::nGiftListSkuId
	oClone:nInsertedByClientId  := ::nInsertedByClientId
	oClone:cInsertedByProfileSystemUserId := ::cInsertedByProfileSystemUserId
	oClone:nItemValue           := ::nItemValue
	oClone:cOmsOrderId          := ::cOmsOrderId
	oClone:nOrderId             := ::nOrderId
	oClone:cOrderMessage        := ::cOrderMessage
	oClone:cOrderMessageFrom    := ::cOrderMessageFrom
	oClone:cOrderMessageTo      := ::cOrderMessageTo
	oClone:cOrderResponseMessage := ::cOrderResponseMessage
	oClone:nSkuId               := ::nSkuId
	oClone:nWishedByClientId    := ::nWishedByClientId
	oClone:cWishedByProfileSystemUserId := ::cWishedByProfileSystemUserId
	oClone:l_IsOrderFinished    := ::l_IsOrderFinished
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GiftListStockKeepingUnitDTO
	Local cSoap := ""
	cSoap += WSSoapValue("DateCreated", ::cDateCreated, ::cDateCreated , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DatePurchased", ::cDatePurchased, ::cDatePurchased , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("FreightAndServicesValue", ::nFreightAndServicesValue, ::nFreightAndServicesValue , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListId", ::nGiftListId, ::nGiftListId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListSkuId", ::nGiftListSkuId, ::nGiftListSkuId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("InsertedByClientId", ::nInsertedByClientId, ::nInsertedByClientId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("InsertedByProfileSystemUserId", ::cInsertedByProfileSystemUserId, ::cInsertedByProfileSystemUserId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ItemValue", ::nItemValue, ::nItemValue , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OmsOrderId", ::cOmsOrderId, ::cOmsOrderId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OrderId", ::nOrderId, ::nOrderId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OrderMessage", ::cOrderMessage, ::cOrderMessage , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OrderMessageFrom", ::cOrderMessageFrom, ::cOrderMessageFrom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OrderMessageTo", ::cOrderMessageTo, ::cOrderMessageTo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("OrderResponseMessage", ::cOrderResponseMessage, ::cOrderResponseMessage , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("SkuId", ::nSkuId, ::nSkuId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("WishedByClientId", ::nWishedByClientId, ::nWishedByClientId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("WishedByProfileSystemUserId", ::cWishedByProfileSystemUserId, ::cWishedByProfileSystemUserId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("_IsOrderFinished", ::l_IsOrderFinished, ::l_IsOrderFinished , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_GiftListStockKeepingUnitDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDateCreated       :=  WSAdvValue( oResponse,"_DATECREATED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDatePurchased     :=  WSAdvValue( oResponse,"_DATEPURCHASED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFreightAndServicesValue :=  WSAdvValue( oResponse,"_FREIGHTANDSERVICESVALUE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftListId        :=  WSAdvValue( oResponse,"_GIFTLISTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftListSkuId     :=  WSAdvValue( oResponse,"_GIFTLISTSKUID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nInsertedByClientId :=  WSAdvValue( oResponse,"_INSERTEDBYCLIENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cInsertedByProfileSystemUserId :=  WSAdvValue( oResponse,"_INSERTEDBYPROFILESYSTEMUSERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nItemValue         :=  WSAdvValue( oResponse,"_ITEMVALUE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cOmsOrderId        :=  WSAdvValue( oResponse,"_OMSORDERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nOrderId           :=  WSAdvValue( oResponse,"_ORDERID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cOrderMessage      :=  WSAdvValue( oResponse,"_ORDERMESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrderMessageFrom  :=  WSAdvValue( oResponse,"_ORDERMESSAGEFROM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrderMessageTo    :=  WSAdvValue( oResponse,"_ORDERMESSAGETO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrderResponseMessage :=  WSAdvValue( oResponse,"_ORDERRESPONSEMESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSkuId             :=  WSAdvValue( oResponse,"_SKUID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nWishedByClientId  :=  WSAdvValue( oResponse,"_WISHEDBYCLIENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cWishedByProfileSystemUserId :=  WSAdvValue( oResponse,"_WISHEDBYPROFILESYSTEMUSERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::l_IsOrderFinished  :=  WSAdvValue( oResponse,"__ISORDERFINISHED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfGiftListStockKeepingUnitDTO

WSSTRUCT Service_ArrayOfGiftListStockKeepingUnitDTO
	WSDATA   oWSGiftListStockKeepingUnitDTO AS Service_GiftListStockKeepingUnitDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfGiftListStockKeepingUnitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfGiftListStockKeepingUnitDTO
	::oWSGiftListStockKeepingUnitDTO := {} // Array Of  Service_GIFTLISTSTOCKKEEPINGUNITDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfGiftListStockKeepingUnitDTO
	Local oClone := Service_ArrayOfGiftListStockKeepingUnitDTO():NEW()
	oClone:oWSGiftListStockKeepingUnitDTO := NIL
	If ::oWSGiftListStockKeepingUnitDTO <> NIL 
		oClone:oWSGiftListStockKeepingUnitDTO := {}
		aEval( ::oWSGiftListStockKeepingUnitDTO , { |x| aadd( oClone:oWSGiftListStockKeepingUnitDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfGiftListStockKeepingUnitDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GIFTLISTSTOCKKEEPINGUNITDTO","GiftListStockKeepingUnitDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGiftListStockKeepingUnitDTO , Service_GiftListStockKeepingUnitDTO():New() )
			::oWSGiftListStockKeepingUnitDTO[len(::oWSGiftListStockKeepingUnitDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfStockKeepingUnitQuantityDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitQuantityDTO
	WSDATA   oWSStockKeepingUnitQuantityDTO AS Service_StockKeepingUnitQuantityDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitQuantityDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitQuantityDTO
	::oWSStockKeepingUnitQuantityDTO := {} // Array Of  Service_STOCKKEEPINGUNITQUANTITYDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitQuantityDTO
	Local oClone := Service_ArrayOfStockKeepingUnitQuantityDTO():NEW()
	oClone:oWSStockKeepingUnitQuantityDTO := NIL
	If ::oWSStockKeepingUnitQuantityDTO <> NIL 
		oClone:oWSStockKeepingUnitQuantityDTO := {}
		aEval( ::oWSStockKeepingUnitQuantityDTO , { |x| aadd( oClone:oWSStockKeepingUnitQuantityDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfStockKeepingUnitQuantityDTO
	Local cSoap := ""
	aEval( ::oWSStockKeepingUnitQuantityDTO , {|x| cSoap := cSoap  +  WSSoapValue("StockKeepingUnitQuantityDTO", x , x , "StockKeepingUnitQuantityDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Enumeration ErrorType

WSSTRUCT Service_ErrorType
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ErrorType
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "CATEGORIA" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "CLIENTE" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "ESTOQUE" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "IMAGEM" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "KIT" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "MARCA" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "PEDIDO" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "PRODUTO" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "SKU" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "SERVICO" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "ENTREGA" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "TRACKING" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "FRETE" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "FRETEVALOR" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "GIFTCARD" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "EMAILQUEUE" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "GIFTLIST" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "GIFTLISTSKU" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "BUYTOGETHER" )
	aadd(::aValueList , "" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Service_ErrorType
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ErrorType
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Service_ErrorType
Local oClone := Service_ErrorType():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfStockKeepingUnitEanDTO

WSSTRUCT Service_ArrayOfStockKeepingUnitEanDTO
	WSDATA   oWSStockKeepingUnitEanDTO AS Service_StockKeepingUnitEanDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfStockKeepingUnitEanDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfStockKeepingUnitEanDTO
	::oWSStockKeepingUnitEanDTO := {} // Array Of  Service_STOCKKEEPINGUNITEANDTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfStockKeepingUnitEanDTO
	Local oClone := Service_ArrayOfStockKeepingUnitEanDTO():NEW()
	oClone:oWSStockKeepingUnitEanDTO := NIL
	If ::oWSStockKeepingUnitEanDTO <> NIL 
		oClone:oWSStockKeepingUnitEanDTO := {}
		aEval( ::oWSStockKeepingUnitEanDTO , { |x| aadd( oClone:oWSStockKeepingUnitEanDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfStockKeepingUnitEanDTO
	Local cSoap := ""
	aEval( ::oWSStockKeepingUnitEanDTO , {|x| cSoap := cSoap  +  WSSoapValue("StockKeepingUnitEanDTO", x , x , "StockKeepingUnitEanDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfStockKeepingUnitEanDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITEANDTO","StockKeepingUnitEanDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStockKeepingUnitEanDTO , Service_StockKeepingUnitEanDTO():New() )
			::oWSStockKeepingUnitEanDTO[len(::oWSStockKeepingUnitEanDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ImageDTO

WSSTRUCT Service_ImageDTO
	WSDATA   nArchiveFormatId          AS int OPTIONAL
	WSDATA   nArchiveParentId          AS int OPTIONAL
	WSDATA   nArchiveTypeId            AS int OPTIONAL
	WSDATA   cDateLastModified         AS dateTime OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   cFileLocation             AS string OPTIONAL
	WSDATA   nHeight                   AS int OPTIONAL
	WSDATA   cHeightUnitMeasure        AS string OPTIONAL
	WSDATA   nId                       AS int OPTIONAL
	WSDATA   lIsMain                   AS boolean OPTIONAL
	WSDATA   cLabel                    AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSDATA   cTag                      AS string OPTIONAL
	WSDATA   cUrl                      AS string OPTIONAL
	WSDATA   nWidth                    AS int OPTIONAL
	WSDATA   cWidthUnitMeasure         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ImageDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ImageDTO
Return

WSMETHOD CLONE WSCLIENT Service_ImageDTO
	Local oClone := Service_ImageDTO():NEW()
	oClone:nArchiveFormatId     := ::nArchiveFormatId
	oClone:nArchiveParentId     := ::nArchiveParentId
	oClone:nArchiveTypeId       := ::nArchiveTypeId
	oClone:cDateLastModified    := ::cDateLastModified
	oClone:cDescription         := ::cDescription
	oClone:cFileLocation        := ::cFileLocation
	oClone:nHeight              := ::nHeight
	oClone:cHeightUnitMeasure   := ::cHeightUnitMeasure
	oClone:nId                  := ::nId
	oClone:lIsMain              := ::lIsMain
	oClone:cLabel               := ::cLabel
	oClone:cName                := ::cName
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
	oClone:cTag                 := ::cTag
	oClone:cUrl                 := ::cUrl
	oClone:nWidth               := ::nWidth
	oClone:cWidthUnitMeasure    := ::cWidthUnitMeasure
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ImageDTO
	Local cSoap := ""
	cSoap += WSSoapValue("ArchiveFormatId", ::nArchiveFormatId, ::nArchiveFormatId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ArchiveParentId", ::nArchiveParentId, ::nArchiveParentId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ArchiveTypeId", ::nArchiveTypeId, ::nArchiveTypeId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("DateLastModified", ::cDateLastModified, ::cDateLastModified , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("FileLocation", ::cFileLocation, ::cFileLocation , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Height", ::nHeight, ::nHeight , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("HeightUnitMeasure", ::cHeightUnitMeasure, ::cHeightUnitMeasure , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsMain", ::lIsMain, ::lIsMain , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Label", ::cLabel, ::cLabel , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Tag", ::cTag, ::cTag , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Url", ::cUrl, ::cUrl , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Width", ::nWidth, ::nWidth , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("WidthUnitMeasure", ::cWidthUnitMeasure, ::cWidthUnitMeasure , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ImageDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nArchiveFormatId   :=  WSAdvValue( oResponse,"_ARCHIVEFORMATID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nArchiveParentId   :=  WSAdvValue( oResponse,"_ARCHIVEPARENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nArchiveTypeId     :=  WSAdvValue( oResponse,"_ARCHIVETYPEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDateLastModified  :=  WSAdvValue( oResponse,"_DATELASTMODIFIED","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFileLocation      :=  WSAdvValue( oResponse,"_FILELOCATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nHeight            :=  WSAdvValue( oResponse,"_HEIGHT","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cHeightUnitMeasure :=  WSAdvValue( oResponse,"_HEIGHTUNITMEASURE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsMain            :=  WSAdvValue( oResponse,"_ISMAIN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cLabel             :=  WSAdvValue( oResponse,"_LABEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nStockKeepingUnitId :=  WSAdvValue( oResponse,"_STOCKKEEPINGUNITID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cTag               :=  WSAdvValue( oResponse,"_TAG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUrl               :=  WSAdvValue( oResponse,"_URL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nWidth             :=  WSAdvValue( oResponse,"_WIDTH","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cWidthUnitMeasure  :=  WSAdvValue( oResponse,"_WIDTHUNITMEASURE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure FieldDTO

WSSTRUCT Service_FieldDTO
	WSDATA   nCategoryId               AS int OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nFieldId                  AS int OPTIONAL
	WSDATA   nFieldTypeId              AS int OPTIONAL
	WSDATA   cFieldTypeName            AS string OPTIONAL
	WSDATA   nFieldValueId             AS int OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   lIsRequired               AS boolean OPTIONAL
	WSDATA   lIsStockKeepingUnit       AS boolean OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FieldDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FieldDTO
Return

WSMETHOD CLONE WSCLIENT Service_FieldDTO
	Local oClone := Service_FieldDTO():NEW()
	oClone:nCategoryId          := ::nCategoryId
	oClone:cDescription         := ::cDescription
	oClone:nFieldId             := ::nFieldId
	oClone:nFieldTypeId         := ::nFieldTypeId
	oClone:cFieldTypeName       := ::cFieldTypeName
	oClone:nFieldValueId        := ::nFieldValueId
	oClone:lIsActive            := ::lIsActive
	oClone:lIsRequired          := ::lIsRequired
	oClone:lIsStockKeepingUnit  := ::lIsStockKeepingUnit
	oClone:cName                := ::cName
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_FieldDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCategoryId        :=  WSAdvValue( oResponse,"_CATEGORYID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFieldId           :=  WSAdvValue( oResponse,"_FIELDID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFieldTypeId       :=  WSAdvValue( oResponse,"_FIELDTYPEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cFieldTypeName     :=  WSAdvValue( oResponse,"_FIELDTYPENAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFieldValueId      :=  WSAdvValue( oResponse,"_FIELDVALUEID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsRequired        :=  WSAdvValue( oResponse,"_ISREQUIRED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsStockKeepingUnit :=  WSAdvValue( oResponse,"_ISSTOCKKEEPINGUNIT","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration StockKeepingUnitComplementDTO.ComplementTypeEnum
/*
WSSTRUCT Service_StockKeepingUnitComplementDTO.ComplementTypeEnum
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitComplementDTO.ComplementTypeEnum
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Accessory" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "Sugestion" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "Similarly" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "Generic" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "ShowTogether" )
	aadd(::aValueList , "" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitComplementDTO.ComplementTypeEnum
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StockKeepingUnitComplementDTO.ComplementTypeEnum
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitComplementDTO.ComplementTypeEnum
Local oClone := Service_StockKeepingUnitComplementDTO.ComplementTypeEnum():New()
	oClone:Value := ::Value
Return oClone
*/
// WSDL Data Structure ProductFieldNameDTO

WSSTRUCT Service_ProductFieldNameDTO
	WSDATA   cfieldName                AS string OPTIONAL
	WSDATA   oWSfieldValues            AS Service_ArrayOfstring OPTIONAL
	WSDATA   nproductid                AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ProductFieldNameDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ProductFieldNameDTO
Return

WSMETHOD CLONE WSCLIENT Service_ProductFieldNameDTO
	Local oClone := Service_ProductFieldNameDTO():NEW()
	oClone:cfieldName           := ::cfieldName
	oClone:oWSfieldValues       := IIF(::oWSfieldValues = NIL , NIL , ::oWSfieldValues:Clone() )
	oClone:nproductid           := ::nproductid
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ProductFieldNameDTO
	Local cSoap := ""
	cSoap += WSSoapValue("fieldName", ::cfieldName, ::cfieldName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, ::oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("productid", ::nproductid, ::nproductid , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Structure ProductFieldIdDTO

WSSTRUCT Service_ProductFieldIdDTO
	WSDATA   nfieldId                  AS int OPTIONAL
	WSDATA   oWSfieldValues            AS Service_ArrayOfstring OPTIONAL
	WSDATA   nproductid                AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ProductFieldIdDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ProductFieldIdDTO
Return

WSMETHOD CLONE WSCLIENT Service_ProductFieldIdDTO
	Local oClone := Service_ProductFieldIdDTO():NEW()
	oClone:nfieldId             := ::nfieldId
	oClone:oWSfieldValues       := IIF(::oWSfieldValues = NIL , NIL , ::oWSfieldValues:Clone() )
	oClone:nproductid           := ::nproductid
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ProductFieldIdDTO
	Local cSoap := ""
	cSoap += WSSoapValue("fieldId", ::nfieldId, ::nfieldId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, ::oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("productid", ::nproductid, ::nproductid , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Structure StockKeepingUnitFieldNameDTO

WSSTRUCT Service_StockKeepingUnitFieldNameDTO
	WSDATA   cfieldName                AS string OPTIONAL
	WSDATA   oWSfieldValues            AS Service_ArrayOfstring OPTIONAL
	WSDATA   nidSku                    AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitFieldNameDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitFieldNameDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitFieldNameDTO
	Local oClone := Service_StockKeepingUnitFieldNameDTO():NEW()
	oClone:cfieldName           := ::cfieldName
	oClone:oWSfieldValues       := IIF(::oWSfieldValues = NIL , NIL , ::oWSfieldValues:Clone() )
	oClone:nidSku               := ::nidSku
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitFieldNameDTO
	Local cSoap := ""
	cSoap += WSSoapValue("fieldName", ::cfieldName, ::cfieldName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("fieldValues", ::oWSfieldValues, ::oWSfieldValues , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("idSku", ::nidSku, ::nidSku , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Enumeration TransactionAction

WSSTRUCT Service_TransactionAction
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_TransactionAction
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Credit" )
	aadd(::aValueList , "" )
	aadd(::aValueList , "Debit" )
	aadd(::aValueList , "" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Service_TransactionAction
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_TransactionAction
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Service_TransactionAction
Local oClone := Service_TransactionAction():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure GiftListMemberDTO

WSSTRUCT Service_GiftListMemberDTO
	WSDATA   nGiftListMemberId         AS int OPTIONAL
	WSDATA   nGiftListId               AS int OPTIONAL
	WSDATA   nClientId                 AS int OPTIONAL
	WSDATA   cTitle                    AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   cSurname                  AS string OPTIONAL
	WSDATA   cMail                     AS string OPTIONAL
	WSDATA   cText1                    AS string OPTIONAL
	WSDATA   cText2                    AS string OPTIONAL
	WSDATA   lIsAdmin                  AS boolean OPTIONAL
	WSDATA   lIsActive                 AS boolean OPTIONAL
	WSDATA   cProfileSystemUserId      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GiftListMemberDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GiftListMemberDTO
Return

WSMETHOD CLONE WSCLIENT Service_GiftListMemberDTO
	Local oClone := Service_GiftListMemberDTO():NEW()
	oClone:nGiftListMemberId    := ::nGiftListMemberId
	oClone:nGiftListId          := ::nGiftListId
	oClone:nClientId            := ::nClientId
	oClone:cTitle               := ::cTitle
	oClone:cName                := ::cName
	oClone:cSurname             := ::cSurname
	oClone:cMail                := ::cMail
	oClone:cText1               := ::cText1
	oClone:cText2               := ::cText2
	oClone:lIsAdmin             := ::lIsAdmin
	oClone:lIsActive            := ::lIsActive
	oClone:cProfileSystemUserId := ::cProfileSystemUserId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GiftListMemberDTO
	Local cSoap := ""
	cSoap += WSSoapValue("GiftListMemberId", ::nGiftListMemberId, ::nGiftListMemberId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("GiftListId", ::nGiftListId, ::nGiftListId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ClientId", ::nClientId, ::nClientId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Title", ::cTitle, ::cTitle , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Surname", ::cSurname, ::cSurname , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Mail", ::cMail, ::cMail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Text1", ::cText1, ::cText1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("Text2", ::cText2, ::cText2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsAdmin", ::lIsAdmin, ::lIsAdmin , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("IsActive", ::lIsActive, ::lIsActive , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("ProfileSystemUserId", ::cProfileSystemUserId, ::cProfileSystemUserId , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_GiftListMemberDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nGiftListMemberId  :=  WSAdvValue( oResponse,"_GIFTLISTMEMBERID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nGiftListId        :=  WSAdvValue( oResponse,"_GIFTLISTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nClientId          :=  WSAdvValue( oResponse,"_CLIENTID","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cTitle             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSurname           :=  WSAdvValue( oResponse,"_SURNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMail              :=  WSAdvValue( oResponse,"_MAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cText1             :=  WSAdvValue( oResponse,"_TEXT1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cText2             :=  WSAdvValue( oResponse,"_TEXT2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsAdmin           :=  WSAdvValue( oResponse,"_ISADMIN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lIsActive          :=  WSAdvValue( oResponse,"_ISACTIVE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cProfileSystemUserId :=  WSAdvValue( oResponse,"_PROFILESYSTEMUSERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure StockKeepingUnitQuantityDTO

WSSTRUCT Service_StockKeepingUnitQuantityDTO
	WSDATA   nQuantity                 AS int OPTIONAL
	WSDATA   nStockKeepingUnitId       AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitQuantityDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitQuantityDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitQuantityDTO
	Local oClone := Service_StockKeepingUnitQuantityDTO():NEW()
	oClone:nQuantity            := ::nQuantity
	oClone:nStockKeepingUnitId  := ::nStockKeepingUnitId
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitQuantityDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Quantity", ::nQuantity, ::nQuantity , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
	cSoap += WSSoapValue("StockKeepingUnitId", ::nStockKeepingUnitId, ::nStockKeepingUnitId , "int", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

// WSDL Data Structure StockKeepingUnitEanDTO

WSSTRUCT Service_StockKeepingUnitEanDTO
	WSDATA   cEan                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_StockKeepingUnitEanDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_StockKeepingUnitEanDTO
Return

WSMETHOD CLONE WSCLIENT Service_StockKeepingUnitEanDTO
	Local oClone := Service_StockKeepingUnitEanDTO():NEW()
	oClone:cEan                 := ::cEan
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_StockKeepingUnitEanDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Ean", ::cEan, ::cEan , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Vtex.Commerce.WebApps.AdminWcfService.Contracts", .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_StockKeepingUnitEanDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEan               :=  WSAdvValue( oResponse,"_EAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


