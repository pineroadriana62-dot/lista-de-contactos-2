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