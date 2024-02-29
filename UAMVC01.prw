#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'

#DEFINE CPO_ZZCN 'ZZC_IDSG|ZZC_SEQSG'

User Function UAMVC01()

Local oBrowse := NIL

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('ZZA')

oBrowse:SetDescription("CADASTRO GRUPO DE SERVIÇOS")

//Adição legenda de cores para filtrar
oBrowse:AddLegend("ZZA_STATUS=='1' " ,"GREEN" ,"ATIVO")
oBrowse:AddLegend("ZZA_STATUS== '2' " , "RED " , "INATIVO")

/*Para fitro pré definido como padrão

IF  __cUserID <> '000000' //Caso UserID seje diferente de 000000 adm somente registro ativo
        oBrowse:SetFilterDefault("ZZA_STATUS=='1'")
EndIf
*/

oBrowse:Activate()

Return (NIL)

Static Function MenuDef()

Local aRotina := {}
aAdd( aRotina, { 'Visualizar', 'VIEWDEF.UAMVC01', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir' , 'VIEWDEF.UAMVC01', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar' , 'VIEWDEF.UAMVC01', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir' , 'VIEWDEF.UAMVC01', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir' , 'VIEWDEF.UAMVC01', 0, 8, 0, NIL } )
aAdd( aRotina, { 'Copiar' , 'VIEWDEF.UAMVC01', 0, 9, 0, NIL } )

Return (aRotina)

Static Function ModelDef()
Local oModel // Modelo de dados que será construído


// Cria a estrutura a ser usada no Modelo de Dados
Local oStr1 := FWFormStruct( 1, 'ZZA' )
Local oStr2 := FWFormStruct( 1, 'ZZB' )
Local oStr3 := FWFormStruct( 1, 'ZZC' )

oModel := MPFormModel():New('ModelName')

// Adiciona ao modelo um componente de formulário
oModel:AddFields('MODEL_ZZA',, oStr1)
oModel:AddGrid('MODEL_ZZB','MODEL_ZZA',oStr2)
oModel:AddGrid('MODEL_ZZC','MODEL_ZZB',oStr3)

//Definindo que codigo sequencia não se repita
oModel:GetModel('MODEL_ZZB'):SetUniqueLine( {'ZZB_SEQ'} )
oModel:GetModel('MODEL_ZZC'):SetUniqueLine( {'ZZC_SEQ'} )

//Relacionando as tabelas
oModel:SetRelation( 'MODEL_ZZB', { { 'ZZB_FILIAL', 'xFilial( "ZZB" ) ' } , { 'ZZB_ID', 'ZZA_ID' } } , ZZB->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_ZZC', { { 'ZZC_FILIAL', 'xFilial( "ZZC" ) ' } , { 'ZZC_IDSG', 'ZZA_ID' } , {'ZZC_SEQSG','ZZB_SEQ'} } , ZZC->( IndexKey( 1 ) ) )

//Chave primaria
oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_ID'})

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'MODEL_ZZA' ):SetDescription( 'CADASTRO GRUPO DE SERVIÇO' )
oModel:GetModel( 'MODEL_ZZB' ):SetDescription( 'SUBGRUPO DE SERVIÇO' )
oModel:GetModel( 'MODEL_ZZC' ):SetDescription( 'CADATRO DE SERVIÇO' )

//Para tornar o preenchimento ZZC opcional 
oModel:GetModel( 'MODEL_ZZC' ):SetOptional(.T.)

// Retorna o Modelo de dados
Return oModel

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado

// Cria o objeto de View
Local oView

Local oModel := FwLoadModel('UAMVC01')

// Cria a estrutura a ser usada na View
Local oStr1 := FWFormStruct( 2, 'ZZA' )
Local oStr2 := FWFormStruct( 2, 'ZZB' )
Local oStr3 := FWFormStruct( 2, 'ZZC' )

// Interface de visualização construída
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário 
oView:AddField( 'VIEW_ZZA', oStr1, 'MODEL_ZZA' )
oView:AddGrid( 'VIEW_ZZB', oStr2, 'MODEL_ZZB' )
oView:AddGrid( 'VIEW_ZZC', oStr3, 'MODEL_ZZC' )

// Cria Folder na view
oView:CreateFolder( 'PASTAS' )

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', 'ZZA ZZB' )
oView:AddSheet( 'PASTAS', 'ABA02', 'ZZC' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'BOX_SUPERIOR' , 60 ,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'BOX_INFERIOR' , 40 ,,, 'PASTAS', 'ABA01')

// Criar "box" horizontal para receber algum elemento da view     ZZC MODELO3
oView:CreateHorizontalBox( 'BOX_ZZC' , 100,/*Owner*/,/*lUsePixel*/, 'PASTAS', 'ABA02' )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_ZZA', 'BOX_SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZZB', 'BOX_INFERIOR' )
oView:SetOwnerView( 'VIEW_ZZC', 'BOX_ZZC' )

//Titulo tela de inclusão
oView:EnableTitleView('VIEW_ZZA','Grupo de Serviço')
oView:EnableTitleView('VIEW_ZZB','Subgrupo de Serviço')
oView:EnableTitleView('VIEW_ZZC',' Serviço ')

//Auto incremnto no campo SEQ
oView:AddIncrementField('VIEW_ZZB','ZZB_SEQ')
oView:AddIncrementField('VIEW_ZZC','ZZC_SEQ')

// Retorna o objeto de View criado
oView:SetCloseonOk({||.T.})


//Tornando campos visiveis a depender do o Usuario
If __cUserID <> '000000'
        oStr1:RemoveField('ZZA_USER')
        oStr1:RemoveField('ZZA_DATA')
        oStr1:RemoveField('ZZA_HORA')

        oStr2:RemoveField('ZZB_DATA')
        oStr2:RemoveField('ZZB_HORA')
EndIf
oStr2:RemoveField('ZZB_ID')
oStr3:RemoveField('ZZC_IDSG')
oStr3:RemoveField('ZZC_SEQSG')

Return oView

