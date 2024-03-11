import { AfterViewInit, Component, ElementRef, HostListener, Input, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { User, Chatroom, Message, UserTypingEvent, APIError } from 'ezajil-js-sdk';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-chatbox',
  templateUrl: './chatbox.component.html',
  styleUrls: ['./chatbox.component.scss']
})
export class ChatboxComponent implements OnInit, OnDestroy {
  @ViewChild('chatHistoryDiv') chatHistoryDivRef!: ElementRef<HTMLDivElement>;
  @ViewChild('chatWindowDiv') chatWindowDivRef!: ElementRef<HTMLDivElement>;
  @ViewChild('textAreaInput') textAreaInputRef!: ElementRef<HTMLTextAreaElement>;
  @Input() currentUser!: User;
  @Input() chatroom!: Chatroom;
  lastScrollPosition: number = 0;
  messagesPagingState: string | null = null;
  messages: Message[] = [];
  userTypingEvent?: UserTypingEvent;
  isLoading: boolean = true;
  messageContent: string = '';
  keyDownTimeout?: any;
  chatroomError?: string;

  constructor(private toastr: ToastrService) { }

  ngOnInit(): void {
    this.chatroom.open();
    this.chatroom
      .on('payload-delivery-error', (code, reason, chatroomId, payload) => {
        this.setChatroomError(`${reason} (${code})`);
        switch (payload.event) {
          case 'chat-message':
            this.messages = this.messages.filter(message => message.messageId !== (payload.payload as Message).messageId);
        }
      })
      .on('chat-message', (chatMessage) => {
        this.addNewMessage(chatMessage);
        this.scrollToBottom();
        // Cancel user typing event rendering if any
        this.userTypingEvent = undefined;
        this.chatroom.markMessageAsRead(chatMessage.sendingDate);
      })
      .on('message-sent', (messageSentEvent) => {
        this.messages = this.messages.map(message => {
          if (messageSentEvent.messageId === message.messageId) {
            return { ...message, status: 'SENT' };
          }
          return message;
        });
      })
      .on('user-typing', (userTypingEvent) => {
        this.userTypingEvent = userTypingEvent;
        this.scrollToBottom();
        setTimeout(() => {
          this.userTypingEvent = undefined;
        }, 6000);
      })
      .on('messages-delivered', (messagesDeliveredEvent) => {
        this.messages = this.messages.map(message => {
          if (message.author === this.currentUser.userId && message.status === 'SENT'
            && messagesDeliveredEvent.latestMessageDelivered >= message.sendingDate) {
            return { ...message, status: 'DELIVERED' };
          }
          return message;
        });
      })
      .on('messages-read', (messagesReadEvent) => {
        this.messages = this.messages.map(message => {
          if (message.author === this.currentUser.userId && ['SENT', 'DELIVERED'].includes(message.status)
            && messagesReadEvent.latestMessageRead >= message.sendingDate) {
            return { ...message, status: 'READ' };
          }
          return message;
        });
      });

    this.messagesPagingState = null;
    this.fetchChatroomMessages();
  }

  private setChatroomError(message: string) {
    this.chatroomError = message;
    setTimeout(() => {
      this.chatroomError = undefined;
    }, 10000);
  }

  private async fetchChatroomMessages(firstCall: boolean = true) {
    try {
      const messages = await this.chatroom.getMessages(this.messagesPagingState, 20);
      this.isLoading = false;
      messages.results.forEach(message => this.addNewMessage(message));
      this.messagesPagingState = messages.pagingState;

      if (messages.results.length > 0) {
        this.chatroom.markMessageAsRead(this.messages[this.messages.length - 1].sendingDate);

        if (firstCall) {
          this.scrollToBottom();
        } else {
          this.scrollToLastPosition();
        }
      }
    } catch (error) {
      const apiError = error as APIError;
      this.toastr.error(apiError.message, 'Error');
    }
  }

  onChatroomScroll(event: Event) {
    const scrollContainer = event.target as HTMLElement;
    const atTop = scrollContainer.scrollTop === 0;
    if (atTop) {
      this.lastScrollPosition = scrollContainer.scrollHeight;
      this.fetchChatroomMessages(false);
    }
  }

  ngOnDestroy(): void {
    this.chatroom.close();
  }

  sendTextMessage(textMessage: string): void {
    const newMessage = this.chatroom.sendChatMessage(textMessage);
    this.addNewMessage(newMessage);
    this.scrollToBottom();
  }

  private addNewMessage(newMessage: Message | null) {
    if (!!newMessage) {
      const insertIndex = this.messages.findIndex((item) => newMessage.sendingDate < item.sendingDate);
      // Check if the newMessage should be placed at the last index
      if (insertIndex === -1) {
        this.messages.push(newMessage);
      } else {
        // Insert the newMessage at the appropriate index
        this.messages.splice(insertIndex, 0, newMessage);
      }
    }
  }

  scrollToBottom(): void {
    setTimeout(() => {
      const messageListElement = this.chatHistoryDivRef.nativeElement;
      messageListElement.scrollTop = messageListElement.scrollHeight;
    }, 300);
  }

  scrollToLastPosition(): void {
    setTimeout(() => {
      const messageListElement = this.chatHistoryDivRef.nativeElement;
      messageListElement.scrollTop = messageListElement.scrollHeight - this.lastScrollPosition;
    }, 0);
  }

  getMessageStatusImage(status: string): string {
    switch (status) {
      case 'READ':
        return 'assets/double-tick-blue.jpg';
      case 'DELIVERED':
        return 'assets/double-tick.jpg';
      case 'SENT':
        return 'assets/tick.jpg';
      default:
        return 'assets/pending.svg';
    }
  }

  onKeyDown(event: any): void {
    this.keyDownDebounce(5000, true, () => this.chatroom.fireUserTyping());
    if ((event.which === 13 || event.keyCode === 13) && !event.shiftKey) {
      const trimmedMessage = this.messageContent.trim();
      if (trimmedMessage !== '') {
        this.sendTextMessage(trimmedMessage);
        clearTimeout(this.keyDownTimeout);
        this.keyDownTimeout = null;
        this.messageContent = '';
        this.textAreaInputRef.nativeElement.style.height = 'auto';
        this.textAreaInputRef.nativeElement.style.overflowY = 'hidden';
      }
    }
  }

  onTextAreaInput(event: any) {
    this.textAreaInputRef.nativeElement.rows = 1;

    if (event.inputType === 'insertLineBreak') {
      this.textAreaInputRef.nativeElement.value = '';
    }

    const rows = Math.ceil((this.textAreaInputRef.nativeElement.scrollHeight - 38 /* initial height of text area */) / 16);
    this.textAreaInputRef.nativeElement.rows = Math.min(rows + 1, 3);

    // Resize chat history paddings 36px (assuming you have chatMessagesDiv and chatBody elements)
    this.chatHistoryDivRef.nativeElement.style.height =
      this.chatWindowDivRef.nativeElement.offsetHeight - this.textAreaInputRef.nativeElement.offsetHeight - 36 + 'px';
  }

  private keyDownDebounce(duration: number, immediate: boolean, callback: (none: void) => void) {
    if (!this.keyDownTimeout) {
      this.keyDownTimeout = setTimeout(() => {
        this.keyDownTimeout = null;
        if (!immediate) {
          callback();
        }
      }, duration);

      if (immediate) {
        callback();
      }
    }
  }

  onFileChange(event: any): void {
    const file = event.target.files[0];
    if (!file) {
      return;
    }

    this.chatroom.uploadFile(file)
      .then(uploadMessage => {
        this.messages = [...this.messages, uploadMessage];
        this.scrollToBottom();
      })
      .catch(error => {
        this.setChatroomError(`${error.message} (${error.status})`);
      });
  }
}
