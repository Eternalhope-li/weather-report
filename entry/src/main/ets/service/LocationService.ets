import geoLocationManager from '@ohos.geoLocationManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import http from '@ohos.net.http';

export interface LocationResult {
  success: boolean;
  city: string;
  errorMsg: string;
}

class LocationService {
  private locationRequestId: number = 0;

  async requestPermission(context: Context): Promise<boolean> {
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

      let appInfo = context.applicationInfo;
      let tokenId: number = appInfo.accessTokenId;

      let granted: boolean = true;
      let perms: Permissions[] = [
        'ohos.permission.APPROXIMATELY_LOCATION' as Permissions,
        'ohos.permission.LOCATION' as Permissions
      ];
      for (let i: number = 0; i < perms.length; i++) {
        let status: abilityAccessCtrl.GrantStatus = atManager.checkAccessTokenSync(tokenId, perms[i]);
        if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          granted = false;
          break;
        }
      }
      if (granted) {
        return true;
      }

      // Pop permission dialog
      await atManager.requestPermissionsFromUser(context, perms);

      // Re-check after dialog
      for (let i: number = 0; i < perms.length; i++) {
        let status: abilityAccessCtrl.GrantStatus = atManager.checkAccessTokenSync(tokenId, perms[i]);
        if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          return false;
        }
      }
      return true;
    } catch (e) {
      console.error('requestPermission error', JSON.stringify(e));
      return false;
    }
  }

  async getCurrentCity(context: Context): Promise<LocationResult> {
    let id: number = ++this.locationRequestId;

    try {
      let enabled: boolean = await geoLocationManager.isLocationEnabled();
      if (!enabled) {
        return { success: false, city: '', errorMsg: '\u5B9A\u4F4D\u670D\u52A1\u672A\u5F00\u542F' };
      }
    } catch (_e) {
      return { success: false, city: '', errorMsg: '\u65E0\u6CD5\u83B7\u53D6\u5B9A\u4F4D\u670D\u52A1\u72B6\u6001' };
    }

    let hasPermission: boolean = await this.requestPermission(context);
    if (!hasPermission) {
      return { success: false, city: '', errorMsg: '\u5B9A\u4F4D\u6743\u9650\u88AB\u62D2\u7EDD' };
    }

    if (id !== this.locationRequestId) {
      return { success: false, city: '', errorMsg: '\u8BF7\u6C42\u5DF2\u53D6\u6D88' };
    }

    try {
      let requestParam: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 10000
      };
      let location: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(requestParam);

      if (id !== this.locationRequestId) {
        return { success: false, city: '', errorMsg: '\u8BF7\u6C42\u5DF2\u53D6\u6D88' };
      }

      let cityName: string = await this.reverseGeocodeHTTP(location.latitude, location.longitude);
      if (cityName.length > 0) {
        return { success: true, city: cityName, errorMsg: '' };
      }
      return { success: false, city: '', errorMsg: '\u65E0\u6CD5\u8BC6\u522B\u5F53\u524D\u4F4D\u7F6E\u7684\u57CE\u5E02' };
    } catch (e) {
      console.error('getCurrentCity error', JSON.stringify(e));
      return { success: false, city: '', errorMsg: '\u5B9A\u4F4D\u5931\u8D25' };
    }
  }

  private async reverseGeocodeHTTP(lat: number, lon: number): Promise<string> {
    let req: http.HttpRequest = http.createHttp();
    try {
      let url: string = 'https://nominatim.openstreetmap.org/reverse?format=json&lat='
        + lat + '&lon=' + lon + '&zoom=10&accept-language=zh';
      let resp: http.HttpResponse = await req.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });
      if (resp.responseCode === 200) {
        interface AddrData {
          city?: string;
          town?: string;
          county?: string;
          village?: string;
          state?: string;
        }
        interface GeoJson {
          address?: AddrData;
          display_name?: string;
        }
        let result: GeoJson = JSON.parse(String(resp.result)) as GeoJson;
        if (result.address !== undefined && result.address !== null) {
          let addr: AddrData = result.address;
          let name: string = '';
          if (addr.city !== undefined) { name = addr.city; }
          else if (addr.town !== undefined) { name = addr.town; }
          else if (addr.county !== undefined) { name = addr.county; }
          else if (addr.village !== undefined) { name = addr.village; }
          if (name.length > 0) {
            return name;
          }
        }
        if (result.display_name !== undefined && result.display_name !== null) {
          let parts: string[] = result.display_name.split(',');
          if (parts.length >= 3) {
            return parts[parts.length - 3].trim();
          }
        }
      }
    } catch (e) {
      console.error('reverseGeocodeHTTP error', JSON.stringify(e));
    } finally {
      req.destroy();
    }
    return '';
  }
}

const locationService: LocationService = new LocationService();
export default locationService;