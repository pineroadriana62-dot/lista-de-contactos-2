/**
 * @typedef {object} Contact
 * @property {string} id - El id del contacto, que es aleatorio.
 * @property {string} name - El nombre y apellido del contactpo.
 * @property {string} phone - El numero telefonico venezolano del contacto.
*/

/** @type {Contact[]} */
let contacts = [];

/**
 * Crea un nuevo contacto
 * @param {object} payload 
 * @param {string} payload.name - El nombre del contacto.
 * @param {string} payload.phone - El numero del contacto
 */
const addContact = (payload) => {
    const id = crypto.randomUUID();
    const newContact = { id, ...payload };
    contacts = contacts.concat(newContact);
}

/**
 * Obtiene los contactos
 */
const getContacts = () => {
    return contacts;
}

/**
 * Elimina un contacto
 * @param {string} id - El id del contacto a eliminar.
 */
const deleteContact = (id) => {
    contacts = contacts.filter(contact => contact.id !== id);
}

/**
 * Guarda los contactos en el navegador.
 */
const saveContactsInBrowser = () => {
    localStorage.setItem('contacts', JSON.stringify(contacts));
}

/**
 * Obtiene los contactos del navegador
 */
const getContactsFromBrowser = () => {
    const contactsInJson = localStorage.getItem('contacts');
    contacts = JSON.parse(contactsInJson) ?? [];
}

/**
 * Edita un contacto
 * @param {string} id - El id del contacto a actualizar.
 * @param {object} payload 
 * @param {string} payload.name - El nombre del contacto.
 * @param {string} payload.phone - El numero del contacto
 */
const updateContact = (id, payload) => {
    contacts = contacts.map(contact => {
        if (contact.id === id) {
            return {
                ...contact, 
                name: payload.name, 
                phone: payload.phone
            }
        } else {
            return contact
        }
    });

    // Otra manera de hacerlo
    // const contactToUpdate = contacts.find(contact => contact.id === id);
    // if (!contactToUpdate) return;
    // const contactUpdated = {...contactToUpdate, name: payload.name, phone: payload.phone};
    // contacts = contacts.map(contact => contact.id === id ? contactUpdated : contact);
}




const contactsService = {
    addContact,
    getContacts,
    deleteContact,
    saveContactsInBrowser,
    getContactsFromBrowser,
    updateContact
}

export default contactsService;
// Importa el servicio para manejar la lógica de datos de los contactos.
import contactsService from "./contacts.js";

// --- SELECTORES DEL DOM ---

// Selectores del formulario principal y sus elementos.
const form = document.querySelector('#main-form');
const inputName = document.querySelector('#name-input');
const inputPhone = document.querySelector('#phone-input');
const formButton = document.querySelector('#main-form-btn');

// Selectores para la lista de contactos y la plantilla de un ítem.
const contactsList = document.querySelector('#contacts-list');
const contactItemTemplate = document.querySelector('#template-contact-item');

// --- CONSTANTES Y ESTADO ---

// Expresiones regulares para validar el formato del nombre y el teléfono.
const NAME_REGEX = /^[A-Z][a-z]*[ ][A-Z][a-z]{3,}[ ]{0,1}$/;
const PHONE_REGEX = /^[0](414|424|416|426|422|412|212)[0-9]{7}$/;

// Variables de estado para la validez de los campos del formulario.
let isValidName = false;
let isValidPhone = false;

// --- FUNCIONES DE RENDERIZADO (LÓGICA DE INTERFAZ) ---

/**
 * Gestiona las clases visuales de un campo de formulario (válido/inválido/por defecto) 
 * y la visibilidad del texto de ayuda.
 * @param {HTMLInputElement} input - El elemento input.
 * @param {boolean} isValid - Indica si el valor del input es válido.
 */
const handleStateInput = (input, isValid) =>{
  const helperText = input.nextElementSibling;  
  if (!input.value) {
    // Estado por defecto (vacío).
    input.classList.remove('input-invalid');
    input.classList.remove('input-valid');
    helperText.classList.remove('show-helper-text');
  } else if (isValid) {
    // Estado de input válido.
    input.classList.add('input-valid');
    input.classList.remove('input-invalid');
    helperText.classList.remove('show-helper-text');
  } else {
    // Estado de input inválido.
    input.classList.add('input-invalid');
    input.classList.remove('input-valid');
    helperText.classList.add('show-helper-text');
  }
}

/**
 * Habilita o deshabilita el botón de enviar del formulario principal 
 * en función de la validez de los campos de nombre y teléfono.
 */
const handleFormBtnState = () => {
  if (isValidName && isValidPhone) {
    formButton.disabled = false;
  } else {
    formButton.disabled = true;
  }
}

/**
 * Renderiza la lista completa de contactos en el DOM, vaciando la lista actual y 
 * creando nuevos elementos a partir de la plantilla.
 * @param {Array<object>} contacts - El array de contactos a renderizar.
 */
const renderContacts = (contacts) => {
  contactsList.innerHTML = '';
  contacts.forEach(contact => {
    // Clona la plantilla para crear el ítem del contacto.
    const li = contactItemTemplate.content.cloneNode(true).children[0];
    li.id = contact.id;

    // Asigna los valores del contacto a los inputs del ítem.
    const liNameInput = li.children[0].children[0];
    const liPhoneInput = li.children[0].children[1];
    
    liNameInput.setAttribute('value', contact.name);
    liPhoneInput.setAttribute('value', contact.phone);
    contactsList.append(li);
  });
}

// --- MANEJADORES DE EVENTOS ---

// Maneja la entrada de datos en el campo de nombre.
inputName.addEventListener('input', e => {
  // LÓGICA DE NEGOCIO (Validación)
  isValidName = NAME_REGEX.test(inputName.value);
  
  // LÓGICA DE RENDERIZADO (Actualización de la UI)
  handleStateInput(inputName, isValidName);
  handleFormBtnState();
});

// Maneja la entrada de datos en el campo de teléfono.
inputPhone.addEventListener('input', e => {
  // LÓGICA DE NEGOCIO (Validación)
  isValidPhone = PHONE_REGEX.test(inputPhone.value);
  
  // LÓGICA DE RENDERIZADO (Actualización de la UI)
  handleStateInput(inputPhone, isValidPhone);
 handleFormBtnState();
});

// Maneja el envío del formulario para añadir un nuevo contacto.
form.addEventListener('submit', e => {
  e.preventDefault();
  
  // LÓGICA DE NEGOCIO (Guardado del contacto y persistencia)
  if (!isValidName || !isValidPhone) return;

  // Añade el contacto usando el servicio.
  contactsService.addContact({
    name: inputName.value,
    phone: inputPhone.value
  });
  // Guarda los contactos en el almacenamiento local.
  contactsService.saveContactsInBrowser();

  // LÓGICA DE RENDERIZADO (Actualización de la lista de contactos)
  const contacts = contactsService.getContacts();
  renderContacts(contacts);
});

// Maneja los eventos de clic dentro de la lista de contactos (Delegación de eventos).
contactsList.addEventListener('click', e => {
  const deleteBtn = e.target.closest('.delete-btn');
  const editBtn = e.target.closest('.edit-btn');

  // LÓGICA PARA ELIMINAR UN CONTACTO
  if (deleteBtn) {
    const li = deleteBtn.parentElement.parentElement;
    
    // LÓGICA DE NEGOCIO
    contactsService.deleteContact(li.id);
    contactsService.saveContactsInBrowser();

    // LÓGICA DE RENDERIZADO
    li.remove();
  }

  // LÓGICA PARA EDITAR O GUARDAR UN CONTACTO
  if (editBtn) {
    // Obtiene los elementos necesarios del DOM.
    const li = editBtn.parentElement.parentElement;
    const id = li.id;
    const liNameInput = li.children[0].children[0];
    const liPhoneInput = li.children[0].children[1];
    const isEditing = li.dataset.editing === 'true';
    const liEditIcon = li.children[1].children[0].children[0];
    
    if (isEditing) {
      // --- LÓGICA DE NEGOCIO (Guardar edición) ---
      console.log('Guardando el contacto');

      // Actualiza el contacto con los nuevos valores.
      contactsService.updateContact(id, {name: liNameInput.value, phone: liPhoneInput.value});
      // Persiste los cambios en el almacenamiento local.
      contactsService.saveContactsInBrowser();
      
      // --- LÓGICA DE RENDERIZADO (Cambiar a modo "no edición") ---
      li.dataset.editing = false;
      // Elimina estilos de edición y restablece el atributo readonly.
      liNameInput.classList.remove('input-is-editing');
      liPhoneInput.classList.remove('input-is-editing');
      liNameInput.setAttribute('readonly', '');
      liPhoneInput.setAttribute('readonly', '');
      // Restablece el ícono a su estado por defecto.
      liEditIcon.name = liEditIcon.dataset.defaultIcon;

    } else {
      // --- LÓGICA DE NEGOCIO (Preparar para editar) ---
      console.log('Empenzando a editar el contacto');
      // Simplemente cambia el estado interno, no hay interacción con el servicio.
      
      // --- LÓGICA DE RENDERIZADO (Cambiar a modo "edición") ---
      li.dataset.editing = true;
      // Añade estilos de edición y quita el atributo readonly.
      liNameInput.classList.add('input-is-editing');
      liPhoneInput.classList.add('input-is-editing');
      liNameInput.removeAttribute('readonly');
      liPhoneInput.removeAttribute('readonly');
      // Cambia el ícono para indicar el modo "guardar".
      liEditIcon.name = 'pencil-outline';
    }
    
  }
});

// --- INICIALIZACIÓN ---

// Función que se ejecuta al cargar la ventana para inicializar la aplicación.
window.onload = () => {
  // LÓGICA DE NEGOCIO (Carga inicial de datos)
  // Carga los contactos almacenados en el navegador.
  contactsService.getContactsFromBrowser();
  
  // LÓGICA DE RENDERIZADO (Muestra los datos cargados)
  // Obtiene los contactos y los renderiza en la interfaz.
  const contacts = contactsService.getContacts();
  renderContacts(contacts);
}
import contactsService from "./contacts.js";

// Selectores
const form = document.querySelector('#main-form');
const inputName = document.querySelector('#name-input');
const inputPhone = document.querySelector('#phone-input');
const formButton = document.querySelector('#main-form-btn');

const contactsList = document.querySelector('#contacts-list');
const contactItemTemplate = document.querySelector('#template-contact-item');


const NAME_REGEX = /^[A-Z][a-z]*[ ][A-Z][a-z]{3,}[ ]{0,1}$/;
const PHONE_REGEX = /^[0](414|424|416|426|422|412|212)[0-9]{7}$/;

let isValidName = false;
let isValidPhone = false;

// Reutilizar la lógica de validación del estado del input
const handleStateInput = (input, isValid) =>{
  const helperText = input.nextElementSibling;
  // Solo aplicamos la lógica si existe un helper text
  if (helperText) {
      if (!input.value) {
          input.classList.remove('input-invalid');
          input.classList.remove('input-valid');
          helperText.classList.remove('show-helper-text');
      } else if (isValid) {
          input.classList.add('input-valid');
          input.classList.remove('input-invalid');
          helperText.classList.remove('show-helper-text');
      } else {
          input.classList.add('input-invalid');
          input.classList.remove('input-valid');
          helperText.classList.add('show-helper-text');
      }
  } else {
      // Lógica para los inputs de edición que no tienen helper text
      if (isValid) {
          input.classList.remove('input-invalid');
      } else {
          input.classList.add('input-invalid');
      }
  }
}

const handleFormBtnState = () => {
  if (isValidName && isValidPhone) {
    formButton.disabled = false;
  } else {
    formButton.disabled = true;
  }
}

const renderContacts = (contacts) => {
  contactsList.innerHTML = '';
  contacts.forEach(contact => {
    const li = contactItemTemplate.content.cloneNode(true).children[0];
    li.id = contact.id;

    const liNameInput = li.children[0].children[0];
    const liPhoneInput = li.children[0].children[1];
    
    liNameInput.setAttribute('value', contact.name);
    liPhoneInput.setAttribute('value', contact.phone);

    // Inicializar el estado de validación en el li
    li.dataset.nameValid = 'true';
    li.dataset.phoneValid = 'true';

    contactsList.append(li);
  });
}

inputName.addEventListener('input', e => {
  isValidName = NAME_REGEX.test(inputName.value);
  handleStateInput(inputName, isValidName);
  handleFormBtnState();
});

inputPhone.addEventListener('input', e => {
  isValidPhone = PHONE_REGEX.test(inputPhone.value);
  handleStateInput(inputPhone, isValidPhone);
  handleFormBtnState();
});

form.addEventListener('submit', e => {
  e.preventDefault();
  if (!isValidName || !isValidPhone) return;
  contactsService.addContact({
    name: inputName.value,
    phone: inputPhone.value
  });
  contactsService.saveContactsInBrowser();
  const contacts = contactsService.getContacts();
  renderContacts(contacts);
});

// Función para manejar el estado del botón de edición/guardado
const handleEditBtnState = (li, editBtn) => {
    const nameValid = li.dataset.nameValid === 'true';
    const phoneValid = li.dataset.phoneValid === 'true';
    editBtn.disabled = !(nameValid && phoneValid);
}

// Función para manejar el input durante la edición
const handleEditInput = (e, li, input, regex, type) => {
    const isValid = regex.test(input.value);
    li.dataset[type + 'Valid'] = isValid.toString(); // Actualizar el estado de validez
    handleStateInput(input, isValid); // Aplicar estilos visuales (sin helper text)
    
    // Encontrar el botón de edición/guardado
    const editBtn = li.querySelector('.edit-btn');
    handleEditBtnState(li, editBtn); // Actualizar el estado del botón
};


contactsList.addEventListener('click', e => {
  const deleteBtn = e.target.closest('.delete-btn');
  const editBtn = e.target.closest('.edit-btn');

  if (deleteBtn) {
    const li = deleteBtn.parentElement.parentElement;
    contactsService.deleteContact(li.id);
    contactsService.saveContactsInBrowser();
    li.remove();
  }

  if (editBtn) {
    const li = editBtn.parentElement.parentElement;
    const id = li.id;
    const liNameInput = li.children[0].children[0];
    const liPhoneInput = li.children[0].children[1];
    const isEditing = li.dataset.editing === 'true';
    const liEditIcon = li.children[1].children[0].children[0];
    
    // Eliminar cualquier listener anterior para evitar duplicados
    liNameInput.removeEventListener('input', li.nameInputHandler);
    liPhoneInput.removeEventListener('input', li.phoneInputHandler);

    if (isEditing) {
      // Lógica para GUARDAR
      const isNameValid = li.dataset.nameValid === 'true';
      const isPhoneValid = li.dataset.phoneValid === 'true';
      
      // SOLO GUARDAR si ambos son válidos
      if (!isNameValid || !isPhoneValid) {
          console.log('No se puede guardar, hay campos inválidos.');
          return; // Detener la acción de guardar si la validación falla
      }

      console.log('Guardando el contacto');
      li.dataset.editing = false;
      liNameInput.classList.remove('input-is-editing');
      liPhoneInput.classList.remove('input-is-editing');
      liNameInput.removeAttribute('class'); // Limpiar clases de validación para edición
      liPhoneInput.removeAttribute('class'); // Limpiar clases de validación para edición
      liNameInput.setAttribute('readonly', '');
      liPhoneInput.setAttribute('readonly', '');
      editBtn.disabled = false; // Asegurar que el botón esté habilitado para la próxima edición
      
      contactsService.updateContact(id, {name: liNameInput.value, phone: liPhoneInput.value});
      contactsService.saveContactsInBrowser();
      liEditIcon.name = liEditIcon.dataset.defaultIcon;

      
    } else {
      // Lógica para EMPEZAR a EDITAR
      console.log('Empenzando a editar el contacto');
      li.dataset.editing = true;

      // Restablecer el estado visual inicial al empezar a editar (basado en el valor actual)
      li.dataset.nameValid = NAME_REGEX.test(liNameInput.value).toString();
      li.dataset.phoneValid = PHONE_REGEX.test(liPhoneInput.value).toString();
      
      // Aplicar estilos para el modo edición
      liNameInput.classList.add('input-is-editing');
      liPhoneInput.classList.add('input-is-editing');
      handleStateInput(liNameInput, li.dataset.nameValid === 'true');
      handleStateInput(liPhoneInput, li.dataset.phoneValid === 'true');

      // Habilitar la edición de los inputs
      liNameInput.removeAttribute('readonly');
      liPhoneInput.removeAttribute('readonly');

      // 1. Crear y asignar las funciones de manejadores
      li.nameInputHandler = (e) => handleEditInput(e, li, liNameInput, NAME_REGEX, 'name');
      li.phoneInputHandler = (e) => handleEditInput(e, li, liPhoneInput, PHONE_REGEX, 'phone');
      
      // 2. Agregar los listeners de 'input' para validación en tiempo real
      liNameInput.addEventListener('input', li.nameInputHandler);
      liPhoneInput.addEventListener('input', li.phoneInputHandler);

      // 3. Establecer el estado inicial del botón (puede que sea inválido al empezar)
      handleEditBtnState(li, editBtn);

      // Cambiar el ícono a 'Guardar' (o el que sea 'pencil-outline' en tu caso)
      liEditIcon.name = 'pencil-outline';
    }
  }
});

window.onload = () => {
  contactsService.getContactsFromBrowser();
  const contacts = contactsService.getContacts();
  renderContacts(contacts);
}
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lista de contactos</title>
  <link rel="stylesheet" href="index.css">
  <link rel="stylesheet" href="../global.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
</head>
<body>
  <main id="main-container">
    <!-- Formulario -->
    <form id="main-form">
      <div class="main-form-input-container">
        <label for="name-input">Nombre</label>
        <input type="text" name="name-input" id="name-input" class="form-input" placeholder="Gabriel Garcia">
          <p class="main-form-helper-text">
            Tiene que tener nombre y apellido. <br>
            Ambos comienzan con mayusculas.
          </p>
      </div>
      <div class="main-form-input-container">
        <label for="phone-input">Numero</label>
        <input type="text" name="phone-input" id="phone-input" class="form-input" placeholder="04122110509">
        <p class="main-form-helper-text">
          Tiene que ser un numero venezolano valido.
        </p>
      </div>
      <button disabled id="main-form-btn">Crear</button>
    </form>
    <!-- Lista -->
    <ul id="contacts-list"></ul>
    <template id="template-contact-item">
      <li class="contacts-list-item" data-editing="false">
        <div class="inputs-container">
          <input class="contacts-list-item-name-input" type="text" value="Gabriel Garcia" readonly>
          <input class="contacts-list-item-phone-input" type="text" value="04122110509" readonly>
        </div>
        <div class="btns-container">
          <button class="edit-btn">
            <ion-icon name="create-outline" data-default-icon="create-outline"></ion-icon>
          </button>
          <button class="delete-btn">
            <ion-icon name="trash-outline"></ion-icon>
          </button>
        </div>
      </li>
    </template>
  </main>
  <script type="module" src="index.js"></script>
  <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
  <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
#main-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  padding: 1rem;
  max-width: 90rem;
  margin: 0 auto;
  gap: 2rem;
}

#main-form {
  padding: 0.5rem;
  border-radius: 0.375rem;
  display: flex;
  border: 1px solid gray;
  flex-direction: column;
  gap: 1rem;
}

.main-form-input-container {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.main-form-input-container > label {
  font-weight: 500;
}

.form-input {
  /* Cambiado de outline a border para que la validación visual sea más clara */
  border: 1px solid gray; 
  outline: none; /* Asegura que no haya un outline por defecto */
  border-radius: 0.375rem;
  padding: 0.5rem;
}

.main-form-helper-text {
  font-size: 0.75rem;
  font-weight: 300;
  color: #dc3545; /* Rojo más estándar */
  display: none;
}

#main-form-btn {
  background-color: #4338ca;
  padding: 0.5rem 1rem;
  color: white;
  text-decoration: none;
  text-align: center;
  text-transform: uppercase;
  font-weight: 500;
  border-radius: 0.375rem;
}

#contacts-list {
  margin: 0;
  padding: 0.5rem;
  list-style: none;
  overflow: auto;
  display: flex;
  flex-direction: column;
  gap: 2rem;
  border-radius: 0.375rem;
  border: 1px solid gray;
  height: 100%;
}

.edit-btn {
  width: 2rem;
  height: 2rem;
}

.delete-btn {
  width: 2rem;
  height: 2rem;
}

.inputs-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  flex-grow: 1;
}

.contacts-list-item-name-input, .contacts-list-item-phone-input {
  width: 100%;
  outline: none;
  border: 1px solid transparent; /* Base transparente para la lista */
  border-radius: 0.375rem;
  padding: 0.5rem;
}

.btns-container {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.contacts-list-item {
  display: flex;
  gap: 1rem;
  justify-content: space-between;
}

#main-form-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pencil-icon {
  display: none;
}

.input-valid {

  border: 2px solid #28a745 !important;
  outline: none;
}

.input-invalid {
  border: 2px solid #dc3545 !important; 
  outline: none;
}

.show-helper-text{
  display: block;
}

.input-is-editing {
  box-shadow: 0 0 0 1px #4338ca;
}

.contacts-list-item-name-input[readonly], .contacts-list-item-phone-input[readonly] {
    border: 1px solid transparent;
    box-shadow: none;
}

@media (min-width: 768px){
  #main-form {
    width: 70%;
  }

  #contacts-list {
    width: 70%;
  }

  .inputs-container {
    flex-wrap: nowrap;
  }

  #main-container {
    align-items: center;
  }
}

@media (min-width: 1024px){
  #main-form {
    width: 50%;
  }

  #contacts-list {
    width: 50%;
  }

}
