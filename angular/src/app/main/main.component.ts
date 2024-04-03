import { Component, Input, OnInit } from '@angular/core';
import { Session, User } from 'ezajil-js-sdk';
import { environment } from '../../environments/environment.secret';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { firstValueFrom, map } from 'rxjs';

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.scss']
})
export class MainComponent implements OnInit {
  @Input() currentUser!: User;
  session!: Session;
  isOnline!: boolean;
  reason!: string;
  code!: number;
  isClientError: boolean = false;
  requestOrigin: string;

  constructor(
    private http: HttpClient
  ) {
    this.requestOrigin = window.location.origin;
  }

  ngOnInit(): void {
    // These are environment variables necessary for the application to run.
    //
    // Instructions for configuring your environment:
    // 1. Copy or rename `environmet.template.ts` file to `environment.secret.ts`.
    // 2. Replace the placeholder values with your actual configuration settings (Create a project in https://dashboard.ezajil.io)
    //    - `endpoint`: This should be the URL to ezajil backend service.
    //    - `apiKey`: This is the key required to authenticate your access.
    // 3. Do no commit `environment.secret.ts` to your version control system (Git). 
    //    This file should be ignored by version control to protect your sensitive information.
    //    Ensure that `environment.secret.ts` is listed in your `.gitignore` file.
    // 4. The application will import values from `environment.secret.ts` for its configuration.
    //    Make sure the file is correctly named and located in the `src/environments/` directory.
    const endpoint = environment.endpoint;
    this.session = new Session(endpoint, this.currentUser, {enableLogging: true});
    this.session
      .on('connected', () => {
        this.isOnline = true;
      })
      .on('disconnected', (code: number, reason: string, isClientError: boolean) => {
        this.isOnline = false;
        if (isClientError) {
          this.reason = reason;
          this.code = code;
          this.isClientError = isClientError;
        }
      })
      .on('error', (event: Event) => {
        console.error(`error: ${JSON.stringify(event)}`);
      });

      // IMPORTANT: This setup function is intended to be called within your client application. However, 
      // the actual retrieval of the access token must be performed by your backend service. This approach 
      // ensures that your API key remains secure and is not exposed to the client side.
      // Set a callback function to fetch the access token. This function should make a request to 
      // YOUR backend service, which then securely communicates with the authentication endpoint 
      // to retrieve the token. The API key should NEVER be included in client-side code or exposed 
      // over the network from the client to the backend.
      this.session.setFetchTokenCallback(() => {
        const apiKey = environment.apiKey;
        const headers = new HttpHeaders()
        .append('api-key', apiKey).append('Content-Type', 'application/json');
        const body = JSON.stringify(this.currentUser);
        const request = this.http.post<{ accessToken: string }>
        (`${endpoint.startsWith('localhost') ? 'http': 'https'}://${endpoint}/api/v1/users/auth`, body,
         { headers: headers })
         .pipe(map(response => response.accessToken));

        return firstValueFrom(request);
      });

      this.session.connect();
  }

}
