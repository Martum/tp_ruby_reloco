require 'rspec'
require '../src/trait'
require '../src/ejecutar_ambos_metodos_resolucion'
require '../src/fold_l_resolucion'

Trait.define do
  name :ModificoEstadoVariable1

  method :modificar_estado do
    self.variable1 = 40
  end
end

Trait.define do
  name :ModificoEstadoVariable2

  method :modificar_estado do
    self.variable2 = 50
  end
end

Trait.define do
  name :Primero

  method :duplicated do
    50
  end
end

Trait.define do
  name :Segundo

  method :duplicated do
    40
  end
end


describe 'Resolver conflictos' do
  it 'si hay dos metodos duplicados y no se define una resolucion, tira error' do
    class TestModificanEstado
      attr_accessor :variable1, :variable2
      uses ModificoEstadoVariable1 + ModificoEstadoVariable2

      def initialize
        @variable1 = 1
        @variable2 = 2
      end
    end

    instancia = TestModificanEstado.new

    expect {instancia.modificar_estado}.to raise_error
  end


  it 'si hay dos metodos duplicados, los tiene que correr en row' do
    class TestModificanEstado1
      attr_accessor :variable1, :variable2
      uses ModificoEstadoVariable1 + (ModificoEstadoVariable2 < {:modificar_estado => EjecutarAmbosMetodosResolucion.new})

      def initialize
        @variable1 = 1
        @variable2 = 2
      end
    end


    instancia = TestModificanEstado1.new
    instancia.modificar_estado

    instancia.variable1.should == 40
    instancia.variable2.should == 50
  end

  it 'si hay dos metodos duplicados, tiene que aplicarle una funcion y devolver el ultimo valor' do
    class TestSumaResultados
      uses Primero + (Segundo < {:duplicated => FoldLResolucion.new(lambda { |un_numero, otro_numero| un_numero + otro_numero})})
    end

    instancia = TestSumaResultados.new

    instancia.duplicated.should == 90
  end

end