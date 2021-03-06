require '../src/trait'

# Clase de la que se instanciaran los objetos-clases Traits
class TraitObject
  attr_accessor :metodos, :hash_resoluciones

  def initialize
    @metodos = Hash.new
    @hash_resoluciones = Hash.new
  end

  def agregar_metodo(nombre_metodo, &bloque)
    metodos[nombre_metodo] = bloque
  end

  def remover_metodo(nombre_metodo)
    metodos.delete(nombre_metodo)
  end

  # Resuelve los conflictos, segun corresponda, de los Traits que se suman
  def resolver_conflicto(nombre_metodo, old_metodo, new_metodo, hash_resoluciones)
    if(hash_resoluciones.has_key?(nombre_metodo))
      hash_resoluciones[nombre_metodo].resolver_conflicto(nombre_metodo, old_metodo, new_metodo)
    else
      Trait.resolver_conflicto_default(nombre_metodo, old_metodo, new_metodo)
    end
  end

  # Une los metodos de dos traits
  def unir_metodos(hash_metodos, hash_resoluciones)
    self.metodos.merge!(hash_metodos) { |key, oldval, newval|
      resolver_conflicto(key, oldval, newval, hash_resoluciones)
    }
  end

  def tengo_metodo?(un_metodo)
    metodos.member?(un_metodo)
  end

  def bloque_metodo(un_metodo)
    metodos[un_metodo]
  end

  # Clona este objeto
  def clonar()
    objeto_clon = self.class.new
    objeto_clon.metodos = self.metodos.clone
    objeto_clon.hash_resoluciones = self.hash_resoluciones.clone
    objeto_clon
  end

  # Agrega un metodo nuevo como alias de uno ya existente
  def crear_alias_metodo(metodo_old, metodo_new)
    agregar_metodo(metodo_new, &bloque_metodo(metodo_old))
  end

  # Restar metodo a Trait
  def -(un_metodo)

    # No existe metodo, raise exception
    if not(self.tengo_metodo?(un_metodo)) then
      raise NoMethodError, "El metodo #{un_metodo} no existe, no se puede restar"
    end

    # Crea una copia de este Objeto, remueve el metodo indicado y devuelve el nuevo objeto
    objeto_clon = self.clonar
    objeto_clon.remover_metodo(un_metodo)
    objeto_clon
  end

  # Suma de Traits
  def +(un_trait)
    objeto_clon = self.clonar
    objeto_clon.unir_metodos(un_trait.metodos, un_trait.hash_resoluciones)
    objeto_clon
  end

  # Alias
  def <<(array_metodos)

    metodo_old = array_metodos.at(0)
    metodo_new = array_metodos.at(1)

    # No existe metodo old, raise exception
    if not(self.tengo_metodo?(metodo_old)) then
      raise NoMethodError, "El metodo #{metodo_old} no existe, no se puede generar alias"
    end

    # Existe metodo new, raise exception
    if self.tengo_metodo?(metodo_new) then
      raise MethodAlreadyExistsError, "El metodo #{metodo_new} ya existe, no se puede generar alias"
    end

    # Crea una copia de este Objeto, aliasea el metodo indicado y devuelve el nuevo objeto
    objeto_clon = self.clonar
    objeto_clon.crear_alias_metodo(metodo_old, metodo_new)
    objeto_clon
  end

  # Hash para Resolver Conflictos
  def <(hash_resoluciones)
    objeto_clon = self.clonar
    objeto_clon.hash_resoluciones.merge!(hash_resoluciones)
    objeto_clon
  end

end