-- | XDR specification, as per RFC4506

module Data.XDR.Specification
  where

import qualified Data.XDR.Types as XDR

newtype Identifier = Identifier{ identifierString :: String }
  deriving (Show, Eq, Ord)

type Length = XDR.UnsignedInt

maxLength :: Length
maxLength = maxBound

data ArrayLength
  = FixedLength    { arrayLength :: !Length }
  | VariableLength { arrayLength :: !Length -- ^defaulted to maxLength
    }

data TypeDescriptor
  = TypeSingle
    { descriptorType :: !TypeSpecifier
    }
  | TypeArray 
    { descriptorType :: !TypeSpecifier
    , descriptorLength :: !ArrayLength
    }
  | TypeOpaque
    { descriptorLength :: !ArrayLength
    }
  | TypeString
    { descriptorLength :: !ArrayLength -- ^only 'VariableArray'
    }
  | TypeOptional
    { descriptorType :: !TypeSpecifier
    }

data TypeSpecifier
  = TypeInt
  | TypeUnsignedInt
  | TypeHyper
  | TypeUnsignedHyper
  | TypeFloat
  | TypeDouble
  | TypeQuadruple
  | TypeBool
  | TypeEnum !EnumBody
  | TypeStruct !StructBody
  | TypeUnion !UnionBody
  | TypeIdentifier !Identifier

-- |Non-void declaration
data Declaration = Declaration
  { declarationIdentifier :: !Identifier
  , declarationType :: TypeDescriptor
  }

-- |'Declaration' or void
type OptionalDeclaration = Maybe Declaration

type EnumValues = [(Identifier, XDR.Int)]

newtype EnumBody = EnumBody
  { enumValues :: EnumValues
  }

boolValues :: EnumValues
boolValues = [(Identifier "FALSE", 0), (Identifier "TRUE", 1)]

newtype StructBody = StructBody
  { structMembers :: [Declaration] -- ^with voids elided
  }

data UnionArm = UnionArm
  { unionCase :: !XDR.Int
  , unionCaseLiteral :: String -- ^The literal string found after "case", for labeling
  , unionDeclaration :: OptionalDeclaration
  }

data UnionBody = UnionBody
  { unionDiscriminant :: !Declaration
  , unionArms :: [UnionArm]
  , unionDefault :: Maybe OptionalDeclaration
  }

data DefinitionBody
  = TypeDef TypeDescriptor
  | Constant Integer

data Definition = Definition
  { definitionIdentifier :: !Identifier
  , definitionBody :: !DefinitionBody
  }

type Specification = [Definition]
